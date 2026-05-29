#if DEBUG && os(macOS)
    import SwiftUI

    struct ShellGitCheckoutPreview: View {
        var body: some View {
            ShellGitExampleRepoView { repoPath in
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        VDemoSection(title: "分支切换", icon: "🔄") {
                            VDemoButtonWithLog("获取当前分支", action: {
                                do {
                                    let branch = try ShellGit.currentBranch(at: repoPath)
                                    return "当前分支: \(branch)"
                                } catch {
                                    return "获取当前分支失败: \(error.localizedDescription)"
                                }
                            })
                            VDemoButtonWithLog("创建并切换新分支", action: {
                                do {
                                    let result = try ShellGit.checkoutNewBranch("demo-branch", at: repoPath)
                                    return "创建并切换分支结果: \(result)"
                                } catch {
                                    return "创建并切换分支失败: \(error.localizedDescription)"
                                }
                            })
                            VDemoButtonWithLog("切换到主分支", action: {
                                do {
                                    let result = try ShellGit.checkout("main", at: repoPath)
                                    return "切换分支结果: \(result)"
                                } catch {
                                    return "切换分支失败: \(error.localizedDescription)"
                                }
                            })
                            VDemoButtonWithLog("强制切换分支", action: {
                                do {
                                    let result = try ShellGit.checkoutForce("main", at: repoPath)
                                    return "强制切换分支结果: \(result)"
                                } catch {
                                    return "强制切换分支失败: \(error.localizedDescription)"
                                }
                            })
                        }

                        VDemoSection(title: "文件检出", icon: "📄") {
                            VDemoButtonWithLog("检出单个文件", action: {
                                do {
                                    let result = try ShellGit.checkoutFile("README.md", at: repoPath)
                                    return "检出文件结果: \(result)"
                                } catch {
                                    return "检出文件失败: \(error.localizedDescription)"
                                }
                            })
                            VDemoButtonWithLog("检出所有文件", action: {
                                do {
                                    let result = try ShellGit.checkoutAllFiles(at: repoPath)
                                    return "检出所有文件结果: \(result)"
                                } catch {
                                    return "检出所有文件失败: \(error.localizedDescription)"
                                }
                            })
                            VDemoButtonWithLog("从指定提交检出文件", action: {
                                do {
                                    // 先获取最新提交哈希
                                    let commit = try ShellGit.lastCommitHash(short: true, at: repoPath)
                                    let result = try ShellGit.checkoutFileFromCommit(commit, file: "README.md", at: repoPath)
                                    return "从提交 \(commit) 检出文件结果: \(result)"
                                } catch {
                                    return "从指定提交检出文件失败: \(error.localizedDescription)"
                                }
                            })
                        }

                        VDemoSection(title: "提交检出", icon: "📍") {
                            VDemoButtonWithLog("切换到指定提交", action: {
                                do {
                                    // 获取倒数第二个提交
                                    let commits = try ShellGit.recentCommits(count: 2, at: repoPath)
                                    if commits.count >= 2 {
                                        let commit = commits[1].hash
                                        let result = try ShellGit.checkoutCommit(commit, at: repoPath)
                                        return "切换到提交 \(commit.prefix(7)) 结果: \(result)"
                                    } else {
                                        return "没有足够的提交记录"
                                    }
                                } catch {
                                    return "切换到指定提交失败: \(error.localizedDescription)"
                                }
                            })
                        }

                        VDemoSection(title: "远程分支", icon: "🌐") {
                            VDemoButtonWithLog("切换到远程分支", action: {
                                do {
                                    // 获取远程分支列表
                                    let remoteBranches = try ShellGit.remoteBranches(at: repoPath)
                                    if let firstRemote = remoteBranches.first, !firstRemote.isEmpty {
                                        let result = try ShellGit.checkoutRemoteBranch(firstRemote, at: repoPath)
                                        return "切换到远程分支 \(firstRemote) 结果: \(result)"
                                    } else {
                                        return "没有可用的远程分支"
                                    }
                                } catch {
                                    return "切换到远程分支失败: \(error.localizedDescription)"
                                }
                            })
                        }
                    }
                    .padding()
                }
            }
        }
    }

    #Preview("ShellGit+Checkout Demo") {
        ShellGitCheckoutPreview()
    }

#endif
