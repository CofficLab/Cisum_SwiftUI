import Foundation
import MagicKit
import OSLog
import SwiftUI

/// 音频后台任务插件
///
/// 负责管理音频相关的后台任务，如文件大小计算、哈希计算等。
/// 当前版本仅提供框架，具体业务任务待后续添加。
actor AudioJobPlugin: SuperPlugin, SuperLog, PluginRegistrant {
    static let emoji = "⚙️"
    static let verbose = true

    // 默认启用
    private static var enabled: Bool {
        return true
    }

    let title = "音频后台任务"
    let description = "处理音频文件的后台任务"
    let iconName = "gearshape.2"
    let isGroup = false

    // MARK: - Plugin Life Cycle

    func onRegister() {
        if Self.verbose {
            os_log("\(self.t)🚀 注册音频后台任务插件")
        }

        // 注册任务
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

        if Self.verbose {
            let allJobs = await manager.getAllJobStatus()
            os_log("\(self.t)📋 已注册 \(allJobs.count) 个任务")
            for job in allJobs {
                os_log("\(self.t)  • \(job.name)")
            }
        }

        // 自动启动文件系统监控任务
        await manager.startJob(fsMonitorJob.identifier)
    }

    /// 启动指定任务
    func startJob(identifier: String) async {
        await AudioJobManager.shared.startJob(identifier)
    }
}

// MARK: - PluginRegistrant

extension AudioJobPlugin {
    @objc static func register() {
        guard Self.enabled else {
            if Self.verbose {
                os_log("\(self.t)⚠️ 插件已禁用")
            }
            return
        }

        if Self.verbose {
            os_log("\(self.t)🚀 Register")
        }

        // 注册顺序设为 2，在 AudioPlugin (1) 之后
        PluginRegistry.registerSync(order: 2) {
            // 创建插件实例并初始化
            let plugin = Self()

            // 异步初始化
            Task {
                await plugin.onRegister()
            }

            return plugin
        }
    }
}

// MARK: - Public API

extension AudioJobPlugin {
    /// 手动启动指定任务
    ///
    /// - Parameter identifier: 任务标识符
    static func start(_ identifier: String) {
        Task {
            await AudioJobManager.shared.startJob(identifier)
        }
    }

    /// 停止指定任务
    ///
    /// - Parameter identifier: 任务标识符
    static func stop(_ identifier: String) {
        Task {
            await AudioJobManager.shared.stopJob(identifier)
        }
    }

    /// 获取所有任务状态
    static func getAllJobs() async -> [JobStatus] {
        await AudioJobManager.shared.getAllJobStatus()
    }
}
