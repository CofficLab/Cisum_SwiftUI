#if DEBUG && os(macOS)
import SwiftUI

    struct ShellGitLogPreview: View {
        @State private var logPage: Int = 0
        @State private var logSize: Int = 10
        @State private var pagedLogs: [String] = []
        @State private var pagedError: String? = nil

        var body: some View {
            ShellGitExampleRepoView { repoPath in
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        VDemoSection(title: "提交日志", icon: "📝") {
                            VDemoButtonWithLog("获取提交日志 (字符串)", action: {
                                do {
                                    let log = try ShellGit.log(limit: 5, at: repoPath)
                                    return "最近5次提交:\n\(log)"
                                } catch {
                                    return "获取提交日志失败: \(error.localizedDescription)"
                                }
                            })
                            VDemoButtonWithLog("获取提交日志 (数组)", action: {
                                do {
                                    let logs = try ShellGit.logArray(limit: 5, at: repoPath)
                                    return logs.isEmpty ? "无提交记录" : logs.joined(separator: "\n")
                                } catch {
                                    return "获取提交日志数组失败: \(error.localizedDescription)"
                                }
                            })
                            VDemoButtonWithLog("未推送到远程的提交", action: {
                                do {
                                    let commits = try ShellGit.unpushedCommits(at: repoPath)
                                    return commits.isEmpty ? "所有提交已同步到远程" : commits.joined(separator: "\n")
                                } catch {
                                    return "获取未推送提交失败: \(error.localizedDescription)"
                                }
                            })
                            VDemoButtonWithLog("带标签的提交列表", action: {
                                do {
                                    let commits = try ShellGit.commitsWithTags(limit: 10, at: repoPath)
                                    if commits.isEmpty { return "无提交" }
                                    return commits.map { c in
                                        if c.tags.isEmpty {
                                            return "\(c.hash.prefix(7))  \(c.message)"
                                        } else {
                                            return "\(c.hash.prefix(7))  \(c.message)  [tags: \(c.tags.joined(separator: ", "))]"
                                        }
                                    }.joined(separator: "\n")
                                } catch {
                                    return "获取带标签的提交失败: \(error.localizedDescription)"
                                }
                            })
                        }
                        VDemoSection(title: "分页获取提交日志", icon: "📄") {
                            HStack(spacing: 10) {
                                Button("上一页") {
                                    if logPage > 0 { logPage -= 1 }
                                    loadPagedLogs(repoPath)
                                }
                                Button("下一页") {
                                    logPage += 1
                                    loadPagedLogs(repoPath)
                                }
                                Text("第 \(logPage) 页，每页 \(logSize) 条")
                            }
                            .padding(.bottom, 4)
                            Button("刷新") { loadPagedLogs(repoPath) }
                            if let pagedError = pagedError {
                                Text("错误: \(pagedError)").foregroundColor(.red)
                            }
                            if !pagedLogs.isEmpty {
                                ScrollView(.horizontal) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        ForEach(pagedLogs, id: \ .self) { log in
                                            Text(log)
                                                .font(.system(size: 12, design: .monospaced))
                                        }
                                    }
                                    .padding(6)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                                }
                                .frame(maxHeight: 180)
                            }
                        }
                        VDemoSection(title: "结构体提交记录", icon: "🧩") {
                            VDemoButtonWithLog("获取 MagicGitCommit 列表", action: {
                                do {
                                    let commits = try ShellGit.commitList(limit: 10, at: repoPath)
                                    if commits.isEmpty { return "无提交" }
                                    let df = DateFormatter()
                                    df.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                    return commits.map { c in
                                        var line = "\(c.hash.prefix(7)) | \(c.author) | \(df.string(from: c.date))\n  \(c.message)"
                                        if !c.tags.isEmpty {
                                            line += "\n  [tags: \(c.tags.joined(separator: ", "))]"
                                        }
                                        return line
                                    }.joined(separator: "\n\n")
                                } catch {
                                    return "获取 MagicGitCommit 列表失败: \(error.localizedDescription)"
                                }
                            })
                        }
                    }
                    .padding()
                    .onAppear { loadPagedLogs(repoPath) }
                }
            }
            .frame(height: 800)
        }

        private func loadPagedLogs(_ repoPath: String) {
            do {
                pagedLogs = try ShellGit.logsWithPagination(page: logPage, size: logSize, at: repoPath)
                pagedError = nil
            } catch {
                pagedLogs = []
                pagedError = error.localizedDescription
            }
        }
    }

// MARK: - Preview

    #Preview("ShellGitLogPreview") {
        ShellGitLogPreview()
    }

    #Preview("ShellGitLogPreview2") {
        ShellGitLogPreview2()
    }

#endif
