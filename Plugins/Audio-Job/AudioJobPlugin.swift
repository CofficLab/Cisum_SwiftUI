import Foundation
import MagicKit
import OSLog
import SwiftUI

/// 音频后台任务插件
///
/// 负责管理音频相关的后台任务，如文件大小计算、哈希计算等。
actor AudioJobPlugin: SuperPlugin, SuperLog {
    static let emoji = "⚙️"
    static let verbose = true
    static var shouldRegister: Bool { true }
    static var order: Int { 5 }

    let description = "处理音频文件的后台任务"
    let iconName = "gearshape.2"
    

    // MARK: - Plugin Life Cycle

    nonisolated func onRegister() {
        Task {
            await registerJobs()
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
}
