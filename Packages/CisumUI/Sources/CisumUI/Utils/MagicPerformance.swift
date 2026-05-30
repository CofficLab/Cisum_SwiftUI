import Foundation
import OSLog
import SwiftUI

/// 性能监控工具类
public class MagicPerformance {
    /// 日志记录器
    internal static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "MagicKit",
        category: "Performance"
    )
    
    /// 测量代码块执行时间
    /// - Parameters:
    ///   - operation: 操作名称
    ///   - file: 调用文件名（默认）
    ///   - function: 调用函数名（默认）
    ///   - line: 调用行号（默认）
    ///   - action: 要执行的代码块
    /// - Returns: 执行时间（秒）
    @discardableResult
    public static func measure(
        _ operation: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line,
        action: () -> Void
    ) -> TimeInterval {
        let start = CFAbsoluteTimeGetCurrent()
        action()
        let diff = CFAbsoluteTimeGetCurrent() - start
        
        logger.debug("⏱️ [\(operation)] 耗时: \(String(format: "%.4f", diff))s [\(file):\(line)]")
        return diff
    }
    
    /// 异步测量代码块执行时间
    /// - Parameters:
    ///   - operation: 操作名称
    ///   - file: 调用文件名（默认）
    ///   - function: 调用函数名（默认）
    ///   - line: 调用行号（默认）
    ///   - action: 要执行的异步代码块
    /// - Returns: 执行时间（秒）
    @discardableResult
    public static func measureAsync(
        _ operation: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line,
        action: () async -> Void
    ) async -> TimeInterval {
        let start = CFAbsoluteTimeGetCurrent()
        await action()
        let diff = CFAbsoluteTimeGetCurrent() - start
        
        logger.debug("⏱️ [\(operation)] 异步耗时: \(String(format: "%.4f", diff))s [\(file):\(line)]")
        return diff
    }
    
    /// 记录内存使用情况
    /// - Parameters:
    ///   - tag: 标记名称
    ///   - file: 调用文件名（默认）
    ///   - function: 调用函数名（默认）
    ///   - line: 调用行号（默认）
    public static func logMemoryUsage(
        _ tag: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            let usedMB = Double(info.resident_size) / 1024.0 / 1024.0
            logger.debug("📊 [\(tag)] 内存使用: \(String(format: "%.2f", usedMB))MB [\(file):\(line)]")
        }
    }
    
    /// 开始一个性能追踪会话
    /// - Parameters:
    ///   - name: 会话名称
    /// - Returns: 性能追踪会话对象
    public static func startSession(_ name: String) -> MagicPerformanceSession {
        return MagicPerformanceSession(name: name)
    }
}

/// 性能追踪会话类
public class MagicPerformanceSession {
    private let name: String
    private let startTime: CFAbsoluteTime
    private var checkpoints: [(name: String, time: CFAbsoluteTime)] = []
    
    fileprivate init(name: String) {
        self.name = name
        self.startTime = CFAbsoluteTimeGetCurrent()
        MagicPerformance.logger.debug("🎬 开始性能追踪会话: [\(name)]")
    }
    
    /// 记录检查点
    /// - Parameter name: 检查点名称
    public func checkpoint(_ name: String) {
        let time = CFAbsoluteTimeGetCurrent()
        checkpoints.append((name, time))
        
        if let lastCheckpoint = checkpoints.dropLast().last {
            let diff = time - lastCheckpoint.time
            MagicPerformance.logger.debug("⏱️ [\(self.name)] 检查点[\(name)] 距上次: \(String(format: "%.4f", diff))s")
        } else {
            let diff = time - startTime
            MagicPerformance.logger.debug("⏱️ [\(self.name)] 检查点[\(name)] 距开始: \(String(format: "%.4f", diff))s")
        }
    }
    
    /// 结束会话并获取报告
    /// - Returns: 性能报告字符串
    @discardableResult
    public func end() -> String {
        let endTime = CFAbsoluteTimeGetCurrent()
        let totalTime = endTime - startTime
        
        var report = "性能追踪报告 [\(name)]\n"
        report += "总耗时: \(String(format: "%.4f", totalTime))s\n"
        
        if !checkpoints.isEmpty {
            report += "检查点详情:\n"
            var lastTime = startTime
            
            for (index, checkpoint) in checkpoints.enumerated() {
                let diff = checkpoint.time - lastTime
                report += "[\(index + 1)] \(checkpoint.name): \(String(format: "%.4f", diff))s\n"
                lastTime = checkpoint.time
            }
        }
        
        MagicPerformance.logger.debug("🏁 \(report)")
        return report
    }
}

#if DEBUG
public struct MagicPerformanceDemo: View {
    @State private var results: [String] = []
    @State private var isRunning = false
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 20) {
            // Results Section
            VStack(alignment: .leading, spacing: 12) {
                Text("性能测试结果")
                    .font(.headline)
                    .padding(.horizontal)
                
                if results.isEmpty {
                    Text("尚未执行任何测试")
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(results, id: \.self) { result in
                            Text(result)
                                .font(.system(.body, design: .monospaced))
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            // Test Buttons Section
            VStack(alignment: .leading, spacing: 12) {
                Text("测试功能")
                    .font(.headline)
                    .padding(.horizontal)
                
                VStack(spacing: 12) {
                    TestButton(
                        icon: "timer",
                        title: "执行简单测试",
                        isDisabled: isRunning
                    ) {
                        withAnimation { simpleTest() }
                    }
                    
                    TestButton(
                        icon: "timer.circle",
                        title: "执行异步测试",
                        isDisabled: isRunning
                    ) {
                        Task(priority: .userInitiated) { @MainActor in 
                            await asyncTest()
                        }
                    }
                    
                    TestButton(
                        icon: "memorychip",
                        title: "内存使用测试",
                        isDisabled: isRunning
                    ) {
                        withAnimation { memoryTest() }
                    }
                    
                    TestButton(
                        icon: "chart.xyaxis.line",
                        title: "会话测试",
                        isDisabled: isRunning
                    ) {
                        withAnimation { sessionTest() }
                    }
                    
                    TestButton(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "复杂流程测试",
                        isDisabled: isRunning
                    ) {
                        Task(priority: .userInitiated) { @MainActor in 
                            await complexTest()
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
        .navigationTitle("性能监控演示")
    }
    
    private struct TestButton: View {
        let icon: String
        let title: String
        let isDisabled: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                HStack {
                    Image(systemName: icon)
                    Text(title)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.primary.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
            .disabled(isDisabled)
        }
    }
    
    private func addResult(_ text: String) {
        withAnimation {
            results.insert(text, at: 0)
        }
    }
    
    private func simpleTest() {
        isRunning = true
        let time = MagicPerformance.measure("简单操作") {
            // 模拟耗时操作
            Thread.sleep(forTimeInterval: 0.5)
        }
        addResult("简单测试完成，耗时: \(String(format: "%.4f", time))s")
        isRunning = false
    }
    
    private func asyncTest() async {
        isRunning = true
        let time = await MagicPerformance.measureAsync("异步操作") {
            // 模拟异步耗时操作
            try? await Task.sleep(nanoseconds: 800_000_000)
        }
        addResult("异步测试完成，耗时: \(String(format: "%.4f", time))s")
        isRunning = false
    }
    
    private func memoryTest() {
        isRunning = true
        // 创建一些临时数据来测试内存使用
        var data: [String] = []
        for i in 0...10000 {
            data.append("测试数据 \(i)")
        }
        MagicPerformance.logMemoryUsage("内存测试")
        addResult("内存测试完成，请查看控制台日志")
        isRunning = false
    }
    
    private func sessionTest() {
        isRunning = true
        let session = MagicPerformance.startSession("测试会话")
        
        // 第一步
        Thread.sleep(forTimeInterval: 0.3)
        session.checkpoint("步骤1")
        
        // 第二步
        Thread.sleep(forTimeInterval: 0.5)
        session.checkpoint("步骤2")
        
        // 第三步
        Thread.sleep(forTimeInterval: 0.2)
        session.checkpoint("步骤3")
        
        let report = session.end()
        addResult("会话测试完成，报告：\n\(report)")
        isRunning = false
    }
    
    private func complexTest() async {
        isRunning = true
        let session = MagicPerformance.startSession("复杂流程")
        
        // 测试简单操作
        let simpleTime = MagicPerformance.measure("子操作1") {
            Thread.sleep(forTimeInterval: 0.2)
        }
        session.checkpoint("简单操作")
        
        // 测试异步操作
        let asyncTime = await MagicPerformance.measureAsync("子操作2") {
            try? await Task.sleep(nanoseconds: 300_000_000)
        }
        session.checkpoint("异步操作")
        
        // 测试内存使用
        MagicPerformance.logMemoryUsage("复杂流程")
        session.checkpoint("内存检查")
        
        let report = session.end()
        addResult("复杂流程测试完成：\n简单操作耗时: \(String(format: "%.4f", simpleTime))s\n异步操作耗时: \(String(format: "%.4f", asyncTime))s\n\(report)")
        isRunning = false
    }
}

#if DEBUG
#Preview("性能监控演示") {
    MagicPerformanceDemo()
}
#endif
#endif 
