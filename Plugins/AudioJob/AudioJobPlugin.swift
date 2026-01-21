import Foundation
import MagicKit
import OSLog
import SwiftUI

/// 音频后台任务插件
///
/// 负责管理音频相关的后台任务，如文件大小计算、哈希计算等。
/// 当前版本仅提供框架，具体业务任务待后续添加。
actor AudioJobPlugin: SuperPlugin, SuperLog {
    static let emoji = "⚙️"
    static let verbose = true

    /// 注册顺序设为 5，在其他音频插件之后执行
    static var order: Int { 5 }

    let title = "音频后台任务"
    let description = "处理音频文件的后台任务"
    let iconName = "gearshape.2"
    

    // MARK: - Plugin Life Cycle

    func onRegister() {
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

        // 自动启动文件系统监控任务
        await manager.startJob(fsMonitorJob.identifier)
    }

    /// 启动指定任务
    func startJob(identifier: String) async {
        await AudioJobManager.shared.startJob(identifier)
    }
}


// MARK: - Public API

