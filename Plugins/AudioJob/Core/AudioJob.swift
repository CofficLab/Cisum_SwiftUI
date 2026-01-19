import Foundation
import OSLog

/// 音频后台任务协议
///
/// 定义后台任务的基本接口，具体任务需要实现此协议。
protocol AudioJob {
    /// 任务唯一标识符
    var identifier: String { get }

    /// 任务名称
    var name: String { get }

    /// 任务描述
    var description: String { get }

    /// 执行任务
    func execute() async throws

    /// 取消任务
    func cancel()
}

/// 任务状态
struct JobStatus {
    let identifier: String
    let name: String
    let isRunning: Bool
}
