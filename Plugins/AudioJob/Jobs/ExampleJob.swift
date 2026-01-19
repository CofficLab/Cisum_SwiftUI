import Foundation
import MagicKit
import OSLog

/// 示例后台任务
///
/// 这是一个示例实现，展示如何创建一个后台任务。
/// 实际使用时，可以根据具体需求创建不同的任务类型。
final class ExampleJob: AudioJob, SuperLog {
    static let verbose = true

    let identifier = "com.cisum.audio.job.example"
    let name = "示例任务"
    let description = "这是一个示例后台任务，用于演示框架的使用"

    private var task: Task<Void, Never>?

    func execute() async throws {
        if Self.verbose {
            os_log("\(self.t)🔄 示例任务开始执行")
        }

        // 模拟一些工作
        for i in 1...5 {
            try Task.checkCancellation()

            if Self.verbose {
                os_log("\(self.t)📊 进度: \(i)/5")
            }

            try await Task.sleep(nanoseconds: 1_000_000_000) // 1秒
        }

        if Self.verbose {
            os_log("\(self.t)✅ 示例任务执行完成")
        }
    }

    func cancel() {
        task?.cancel()

        if Self.verbose {
            os_log("\(self.t)⏹️ 示例任务已取消")
        }
    }
}
