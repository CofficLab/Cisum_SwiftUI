import Foundation
import OSLog
import SwiftUI

#if os(iOS)
    // iOS 不支持本地 shell 执行，提供受限占位实现，避免在 iOS 目标下编译失败
    @available(iOS 13.0, *)
    class Shell: SuperLog {
        static let emoji = "🐚"

        static func run(_ command: String, at path: String? = nil, verbose: Bool = false) async throws -> String {
            throw ShellError.commandFailed("Shell is unavailable on iOS", command)
        }

        @discardableResult
        static func runSync(_ command: String, at path: String? = nil, verbose: Bool = false) throws -> String {
            throw ShellError.commandFailed("Shell is unavailable on iOS", command)
        }

        static func runMultiple(_ commands: [String], at path: String? = nil, verbose: Bool = false) throws -> [String] {
            throw ShellError.commandFailed("Shell is unavailable on iOS", commands.joined(separator: "; "))
        }

        static func runWithStatus(_ command: String, at path: String? = nil, verbose: Bool = false) -> (output: String, exitCode: Int32) {
            ("Shell is unavailable on iOS", -1)
        }

        static func isCommandAvailable(_ command: String) -> Bool { false }
        static func getCommandPath(_ command: String) -> String? { nil }
        static func configureGitCredentialCache() -> String { "Shell is unavailable on iOS" }
    }
#endif

#if os(macOS)

    /// Shell命令执行的核心类
    /// 提供基础的Shell命令执行功能
    public class Shell: SuperLog {
        public static let emoji = "🐚"

        /// 异步执行Shell命令
        /// - Parameters:
        ///   - command: 要执行的命令
        ///   - path: 执行命令的工作目录（可选）
        ///   - verbose: 是否输出详细日志
        /// - Returns: 命令执行结果
        /// - Throws: 执行失败时抛出错误
        public static func run(_ command: String, at path: String? = nil, verbose: Bool = false) async throws -> String {
            return try await withCheckedThrowingContinuation { continuation in
                // 在后台队列执行，避免阻塞调用线程
                DispatchQueue.global(qos: .userInitiated).async {
                    let process = Process()
                    process.executableURL = URL(fileURLWithPath: "/bin/bash")
                    process.arguments = ["-c", command]

                    if let path = path {
                        process.currentDirectoryURL = URL(fileURLWithPath: path)
                    }

                    let outputPipe = Pipe()
                    let errorPipe = Pipe()
                    process.standardOutput = outputPipe
                    process.standardError = errorPipe

                    do {
                        try process.run()

                        // 使用同步方式读取数据，避免异步handler的竞态条件
                        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
                        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()

                        // 等待进程完成
                        process.waitUntilExit()

                        // 转换数据到字符串
                        let output = String(data: outputData, encoding: .utf8) ?? ""
                        let errorOutput = String(data: errorData, encoding: .utf8) ?? ""

                        // 合并标准输出和错误输出
                        let combinedOutput = errorOutput.isEmpty ? output : "\(output)\n\(errorOutput)"

                        if verbose {
                            os_log("\(self.t) \n➡️ Path: \n\(path ?? "Current Directory") (\(FileManager.default.currentDirectoryPath)) \n➡️ Command: \n\(command) \n➡️ Output: \n\(combinedOutput)")
                        }

                        if process.terminationStatus != 0 {
                            os_log(.error, "\(self.t) ❌ Command failed \n ➡️ Path: \(path ?? "Current Directory") (\(FileManager.default.currentDirectoryPath)) \n ➡️ Command: \(command) \n ➡️ Output: \(combinedOutput) \n ➡️ Exit code: \(process.terminationStatus)")
                            continuation.resume(throwing: ShellError.commandFailed(combinedOutput, command))
                        } else {
                            let trimmedOutput = output.trimmingCharacters(in: .whitespacesAndNewlines)
                            continuation.resume(returning: trimmedOutput)
                        }
                    } catch {
                        continuation.resume(throwing: ShellError.processStartFailed(error.localizedDescription))
                    }
                }
            }
        }

        /// 同步执行Shell命令（向后兼容，内部调用异步版本）
        /// - Parameters:
        ///   - command: 要执行的命令
        ///   - path: 执行命令的工作目录（可选）
        ///   - verbose: 是否输出详细日志
        /// - Returns: 命令执行结果
        /// - Throws: 执行失败时抛出错误
        @discardableResult
        public static func runSync(_ command: String, at path: String? = nil, verbose: Bool = false) throws -> String {
            // 使用 DispatchSemaphore 来同步等待异步操作完成
            var result: Result<String, Error>?
            let semaphore = DispatchSemaphore(value: 0)

            Task {
                do {
                    let output = try await run(command, at: path, verbose: verbose)
                    result = .success(output)
                } catch {
                    result = .failure(error)
                }
                semaphore.signal()
            }

            // 等待异步任务完成
            semaphore.wait()

            switch result! {
            case let .success(output):
                return output
            case let .failure(error):
                throw error
            }
        }

        /// 执行多个命令
        /// - Parameters:
        ///   - commands: 命令数组
        ///   - path: 执行命令的工作目录（可选）
        ///   - verbose: 是否输出详细日志
        /// - Returns: 所有命令的执行结果数组
        /// - Throws: 任何命令执行失败时抛出错误
        public static func runMultiple(_ commands: [String], at path: String? = nil, verbose: Bool = false) throws -> [String] {
            var results: [String] = []

            for command in commands {
                let result = try runSync(command, at: path, verbose: verbose)
                results.append(result)
            }

            return results
        }

        /// 执行命令并返回退出状态码
        /// - Parameters:
        ///   - command: 要执行的命令
        ///   - path: 执行命令的工作目录（可选）
        ///   - verbose: 是否输出详细日志
        /// - Returns: 元组包含输出和退出状态码
        public static func runWithStatus(_ command: String, at path: String? = nil, verbose: Bool = false) -> (output: String, exitCode: Int32) {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/bin/bash")
            process.arguments = ["-c", command]

            if let path = path {
                process.currentDirectoryURL = URL(fileURLWithPath: path)
            }

            let pipe = Pipe()
            process.standardOutput = pipe
            process.standardError = pipe

            let outputHandle = pipe.fileHandleForReading
            var outputData = Data()

            // 使用信号量来确保数据读取完成
            let semaphore = DispatchSemaphore(value: 0)
            var isReadingComplete = false

            outputHandle.readabilityHandler = { handle in
                let data = handle.availableData
                if data.isEmpty {
                    // 数据读取完成
                    isReadingComplete = true
                    semaphore.signal()
                } else {
                    outputData.append(data)
                }
            }

            do {
                try process.run()
                process.waitUntilExit()
            } catch {
                return ("执行失败: \(error.localizedDescription)", -1)
            }

            // 等待数据读取完成，最多等待1秒
            let result = semaphore.wait(timeout: .now() + 1.0)

            // 清理 handler
            outputHandle.readabilityHandler = nil

            // 如果超时，尝试读取剩余数据
            if result == .timedOut || !isReadingComplete {
                let remainingData = outputHandle.readDataToEndOfFile()
                if !remainingData.isEmpty {
                    outputData.append(remainingData)
                }
            }

            guard let output = String(data: outputData, encoding: .utf8) else {
                return ("字符串转换失败: 无法将输出数据转换为UTF-8字符串，数据大小: \(outputData.count) 字节", -2)
            }

            if verbose {
                os_log("\(self.t)\(command)")
                os_log("\(output)")
                os_log("\(self.t)Exit code: \(process.terminationStatus)")
            }

            return (output.trimmingCharacters(in: .whitespacesAndNewlines), process.terminationStatus)
        }

        /// 检查命令是否可用
        /// - Parameter command: 命令名
        /// - Returns: 命令是否可用
        public static func isCommandAvailable(_ command: String) -> Bool {
            do {
                _ = try runSync("which \(command)")
                return true
            } catch {
                return false
            }
        }

        /// 获取命令的完整路径
        /// - Parameter command: 命令名
        /// - Returns: 命令的完整路径
        public static func getCommandPath(_ command: String) -> String? {
            do {
                let path = try runSync("which \(command)")
                return path.isEmpty ? nil : path
            } catch {
                return nil
            }
        }

        /// 配置Git凭证缓存
        /// - Returns: 配置结果
        public static func configureGitCredentialCache() -> String {
            do {
                return try self.runSync("git config --global credential.helper cache")
            } catch {
                return error.localizedDescription
            }
        }
    }

#endif

// MARK: - Preview

#if DEBUG && os(macOS)
    #Preview("Shell Demo") {
        ShellDemoView()
            .padding()
    }
#endif
