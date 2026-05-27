import Combine
import Foundation
import MagicKit
import OSLog
import SwiftUI

/// 用于持有通知观察者的辅助类
@MainActor
private final class NotificationObserverHolder {
    static let shared = NotificationObserverHolder()
    var cancellables = Set<AnyCancellable>()
    private init() {}
}

/// 音频后台任务插件
///
/// 负责管理音频相关的后台任务，如文件大小计算、哈希计算等。
actor AudioJobPlugin: SuperPlugin, SuperLog {
    static let shared = AudioJobPlugin()
    static let emoji = "⚙️"
    static let verbose = false
    static var shouldRegister: Bool { true }
    static var order: Int { 5 }

    let description = "处理音频文件的后台任务"
    let iconName = "gearshape.2"

    // MARK: - Plugin Life Cycle

    nonisolated func onRegister() {
        Task {
            await registerJobs()
            await setupStorageLocationObserver()
        }
    }

    /// 注册任务
    private func registerJobs() async {
        let manager = AudioJobManager.shared

        // 注册文件系统监控任务
        let fsMonitorJob = FileSystemMonitorJob()
        await manager.register(fsMonitorJob)

        // 自动启动文件系统监控任务
        await manager.startJob(fsMonitorJob.identifier)
    }

    /// 启动指定任务
    func startJob(identifier: String) async {
        await AudioJobManager.shared.startJob(identifier)
    }

    // MARK: - Storage Location Monitoring

    /// 设置存储位置变化监听
    private func setupStorageLocationObserver() async {
        await MainActor.run {
            // 监听存储位置重置事件
            NotificationCenter.default.publisher(for: .storageLocationDidReset)
                .sink { [weak self] _ in
                    Task {
                        await self?.restartFileSystemMonitor()
                    }
                }
                .store(in: &NotificationObserverHolder.shared.cancellables)

            // 监听存储位置更新事件
            NotificationCenter.default.publisher(for: .storageLocationUpdated)
                .sink { [weak self] _ in
                    Task {
                        await self?.restartFileSystemMonitor()
                    }
                }
                .store(in: &NotificationObserverHolder.shared.cancellables)
        }
    }

    /// 重启文件系统监控任务
    private func restartFileSystemMonitor() async {
        let manager = AudioJobManager.shared
        let identifier = FileSystemMonitorJob().identifier

        if Self.verbose {
            os_log("\(Self.t)🔄 存储位置变化，重启文件系统监控")
        }

        // 停止旧的监控
        await manager.stopJob(identifier)

        // 短暂延迟，确保旧监控完全停止
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1秒

        // 启动新的监控（会获取新的路径）
        await manager.startJob(identifier)

        if Self.verbose {
            os_log("\(Self.t)✅ 文件系统监控已重启")
        }
    }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
