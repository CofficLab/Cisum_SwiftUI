#if DEBUG && os(macOS)
import SwiftUI

struct ShellDemoView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("🐚 Shell 核心功能演示")
                .font(.title)
                .bold()

            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    VDemoSection(title: "基础命令", icon: "⚡") {
                        VDemoButtonWithLog("获取当前目录", action: {
                            do {
                                let pwd = try Shell.runSync("pwd")
                                return "当前目录: \(pwd)"
                            } catch {
                                return "获取当前目录失败: \(error.localizedDescription)"
                            }
                        })

                        VDemoButtonWithLog("获取当前用户", action: {
                            do {
                                let user = try Shell.runSync("whoami")
                                return "当前用户: \(user)"
                            } catch {
                                return "获取当前用户失败: \(error.localizedDescription)"
                            }
                        })

                        VDemoButtonWithLog("获取系统时间", action: {
                            do {
                                let date = try Shell.runSync("date")
                                return "系统时间: \(date)"
                            } catch {
                                return "获取系统时间失败: \(error.localizedDescription)"
                            }
                        })
                    }

                    VDemoSection(title: "命令检查", icon: "🔍") {
                        VCommandAvailabilityRow("git")
                        VCommandAvailabilityRow("node")
                        VCommandAvailabilityRow("python3")
                        VCommandAvailabilityRow("docker")
                        VCommandAvailabilityRow("nonexistent_command")
                    }

                    VDemoSection(title: "多命令执行", icon: "📋") {
                        VDemoButtonWithLog("执行多个命令", action: {
                            do {
                                let commands = ["echo 'Hello'", "echo 'World'", "date"]
                                let results = try Shell.runMultiple(commands)
                                return "多命令执行结果:\n" + results.enumerated().map { "命令\($0.offset + 1): \($0.element)" }.joined(separator: "\n")
                            } catch {
                                return "多命令执行失败: \(error.localizedDescription)"
                            }
                        })
                    }

                    VDemoSection(title: "状态码检查", icon: "📊") {
                        VDemoButtonWithLog("成功命令（echo）", action: {
                            let (output, exitCode) = Shell.runWithStatus("echo 'Hello World'")
                            return "输出: \(output)\n退出码: \(exitCode)"
                        })

                        VDemoButtonWithLog("失败命令（不存在的命令）", action: {
                            let (output, exitCode) = Shell.runWithStatus("nonexistent_command_12345")
                            return "输出: \(output)\n退出码: \(exitCode)"
                        })
                    }

                    VDemoSection(title: "异步执行", icon: "⏱️") {
                        VAsyncCommandButton()
                    }

                    VDemoSection(title: "Git配置", icon: "🔧") {
                        VDemoButtonWithLog("配置Git凭证缓存", action: {
                            let result = Shell.configureGitCredentialCache()
                            return "Git凭证缓存配置结果: \(result)"
                        })
                    }

                    VDemoSection(title: "错误处理", icon: "⚠️") {
                        VDemoButtonWithLog("测试字符串转换错误", action: {
                            // 注意：这个测试在正常情况下不会触发错误，因为大多数命令输出都是有效的UTF-8
                            // 这里只是展示错误处理的结构
                            do {
                                let result = try Shell.runSync("echo 'Test UTF-8 conversion'")
                                return "字符串转换成功: \(result)"
                            } catch let error as ShellError {
                                switch error {
                                case let .stringConversionFailed(data):
                                    return "字符串转换失败: 数据大小 \(data.count) 字节"
                                case let .commandFailed(output, command):
                                    return "命令执行失败: \(command)\n输出: \(output)"
                                case let .processStartFailed(message):
                                    return "进程启动失败: \(message)"
                                }
                            } catch {
                                return "未知错误: \(error.localizedDescription)"
                            }
                        })
                    }

                    VDemoSection(title: "稳定性测试", icon: "🔄") {
                        VDemoButtonWithLog("测试 git diff-tree 稳定性", action: {
                            // 模拟你遇到的问题：多次执行同一个 git 命令
                            var results: [String] = []
                            let testCommand = "git log --oneline -1"

                            for i in 1 ... 5 {
                                do {
                                    let result = try Shell.runSync(testCommand)
                                    let status = result.isEmpty ? "❌ 空结果" : "✅ 正常"
                                    results.append("第\(i)次: \(status) - 长度: \(result.count)")
                                } catch {
                                    results.append("第\(i)次: ❌ 错误 - \(error.localizedDescription)")
                                }
                            }

                            return "Git命令稳定性测试结果:\n" + results.joined(separator: "\n")
                        })

                        VDemoButtonWithLog("测试快速连续执行", action: {
                            // 测试快速连续执行多个命令
                            var results: [String] = []
                            let commands = ["echo 'test1'", "echo 'test2'", "echo 'test3'", "date", "whoami"]

                            for (index, command) in commands.enumerated() {
                                do {
                                    let result = try Shell.runSync(command)
                                    let status = result.isEmpty ? "❌ 空结果" : "✅ 正常"
                                    results.append("命令\(index + 1): \(status) - \(result.prefix(20))")
                                } catch {
                                    results.append("命令\(index + 1): ❌ 错误 - \(error.localizedDescription)")
                                }
                            }

                            return "快速连续执行测试结果:\n" + results.joined(separator: "\n")
                        })
                    }

                    VDemoSection(title: "并发安全性测试", icon: "🔄") {
                        VDemoButtonWithLog("测试并发执行安全性", action: {
                            // 测试多个Shell.run同时执行
                            var results: [String] = []
                            let group = DispatchGroup()
                            let queue = DispatchQueue.global(qos: .userInitiated)
                            let resultQueue = DispatchQueue(label: "results", attributes: .concurrent)

                            // 同时执行10个不同的命令
                            let commands = [
                                "echo 'Task 1: $(date)'",
                                "echo 'Task 2: $(whoami)'",
                                "echo 'Task 3: $(pwd)'",
                                "echo 'Task 4: $(uname)'",
                                "echo 'Task 5: $(id -u)'",
                                "sleep 0.1 && echo 'Task 6: Delayed'",
                                "echo 'Task 7: $(hostname)'",
                                "echo 'Task 8: $(echo hello)'",
                                "echo 'Task 9: $(date +%s)'",
                                "echo 'Task 10: Final'",
                            ]

                            for (index, command) in commands.enumerated() {
                                group.enter()
                                queue.async {
                                    do {
                                        let result = try Shell.runSync(command)
                                        resultQueue.async(flags: .barrier) {
                                            results.append("命令\(index + 1): \(result)")
                                        }
                                    } catch {
                                        resultQueue.async(flags: .barrier) {
                                            results.append("命令\(index + 1): 错误 - \(error.localizedDescription)")
                                        }
                                    }
                                    group.leave()
                                }
                            }

                            // 等待所有任务完成
                            group.wait()

                            return "并发执行测试结果 (\(results.count)/\(commands.count) 完成):\n" + results.sorted().joined(separator: "\n")
                        })

                        VDemoButtonWithLog("测试Git命令并发安全性", action: {
                            // 测试多个git命令同时执行（如果在git仓库中）
                            var results: [String] = []
                            let group = DispatchGroup()
                            let queue = DispatchQueue.global(qos: .userInitiated)
                            let resultQueue = DispatchQueue(label: "git-results", attributes: .concurrent)

                            // 同时执行多个git命令
                            let gitCommands = [
                                "git --version",
                                "git status --porcelain",
                                "git branch --show-current",
                                "git log --oneline -1",
                                "git config user.name",
                            ]

                            for (index, command) in gitCommands.enumerated() {
                                group.enter()
                                queue.async {
                                    do {
                                        let result = try Shell.runSync(command)
                                        resultQueue.async(flags: .barrier) {
                                            results.append("Git命令\(index + 1): \(result.isEmpty ? "(空结果)" : result)")
                                        }
                                    } catch {
                                        resultQueue.async(flags: .barrier) {
                                            results.append("Git命令\(index + 1): 错误 - \(error.localizedDescription)")
                                        }
                                    }
                                    group.leave()
                                }
                            }

                            // 等待所有任务完成
                            group.wait()

                            return "Git并发执行测试结果 (\(results.count)/\(gitCommands.count) 完成):\n" + results.sorted().joined(separator: "\n")
                        })

                        VDemoButtonWithLog("测试异步Shell.run并发", action: {
                            // 测试异步版本的并发安全性
                            var results: [String] = []
                            let group = DispatchGroup()
                            let resultQueue = DispatchQueue(label: "async-results", attributes: .concurrent)

                            let commands = [
                                "echo 'Async 1'",
                                "echo 'Async 2'",
                                "echo 'Async 3'",
                                "echo 'Async 4'",
                                "echo 'Async 5'",
                            ]

                            for (index, command) in commands.enumerated() {
                                group.enter()
                                Task {
                                    do {
                                        let result = try await Shell.run(command)
                                        resultQueue.async(flags: .barrier) {
                                            results.append("异步任务\(index + 1): \(result)")
                                        }
                                    } catch {
                                        resultQueue.async(flags: .barrier) {
                                            results.append("异步任务\(index + 1): 错误 - \(error.localizedDescription)")
                                        }
                                    }
                                    group.leave()
                                }
                            }

                            // 等待所有任务完成
                            group.wait()

                            return "异步并发测试结果 (\(results.count)/\(commands.count) 完成):\n" + results.sorted().joined(separator: "\n")
                        })
                    }
                }
                .padding()
            }
        }
    }
}

#Preview("Shell Demo") {
    ShellDemoView()
        .padding()
        
}

#endif
