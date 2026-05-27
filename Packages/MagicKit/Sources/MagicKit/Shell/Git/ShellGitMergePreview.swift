#if DEBUG && os(macOS)
import SwiftUI

struct ShellGitMergePreview: View {
    var body: some View {
        ShellGitExampleRepoView { repoPath in
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    VDemoSection(title: "分支合并", icon: "🔀") {
                        VDemoButtonWithLog("普通合并", action: {
                            do {
                                // 先创建一个测试分支
                                _ = try? ShellGit.createBranch("test-merge-branch", at: repoPath)
                                let result = try ShellGit.merge("test-merge-branch", at: repoPath)
                                return "合并结果: \(result)"
                            } catch {
                                return "合并失败: \(error.localizedDescription)"
                            }
                        })
                        VDemoButtonWithLog("快进合并", action: {
                            do {
                                _ = try? ShellGit.createBranch("fast-forward-branch", at: repoPath)
                                let result = try ShellGit.mergeFastForward("fast-forward-branch", at: repoPath)
                                return "快进合并结果: \(result)"
                            } catch {
                                return "快进合并失败: \(error.localizedDescription)"
                            }
                        })
                        VDemoButtonWithLog("非快进合并", action: {
                            do {
                                _ = try? ShellGit.createBranch("no-ff-branch", at: repoPath)
                                let result = try ShellGit.mergeNoFastForward("no-ff-branch", message: "合并 no-ff-branch", at: repoPath)
                                return "非快进合并结果: \(result)"
                            } catch {
                                return "非快进合并失败: \(error.localizedDescription)"
                            }
                        })
                        VDemoButtonWithLog("压缩合并", action: {
                            do {
                                _ = try? ShellGit.createBranch("squash-branch", at: repoPath)
                                let result = try ShellGit.mergeSquash("squash-branch", at: repoPath)
                                return "压缩合并结果: \(result)"
                            } catch {
                                return "压缩合并失败: \(error.localizedDescription)"
                            }
                        })
                    }
                    
                    VDemoSection(title: "合并策略", icon: "🎯") {
                        VDemoButtonWithLog("使用递归策略合并", action: {
                            do {
                                _ = try? ShellGit.createBranch("recursive-branch", at: repoPath)
                                let result = try ShellGit.mergeWithStrategy("recursive-branch", strategy: "recursive", at: repoPath)
                                return "递归策略合并结果: \(result)"
                            } catch {
                                return "递归策略合并失败: \(error.localizedDescription)"
                            }
                        })
                        VDemoButtonWithLog("使用 ours 策略合并", action: {
                            do {
                                _ = try? ShellGit.createBranch("ours-branch", at: repoPath)
                                let result = try ShellGit.mergeWithStrategy("ours-branch", strategy: "ours", at: repoPath)
                                return "ours 策略合并结果: \(result)"
                            } catch {
                                return "ours 策略合并失败: \(error.localizedDescription)"
                            }
                        })
                    }
                    
                    VDemoSection(title: "合并状态", icon: "📊") {
                        VDemoButtonWithLog("检查合并状态", action: {
                            do {
                                let isMerging = try ShellGit.isMerging(at: repoPath)
                                return "是否正在合并: \(isMerging ? "是" : "否")"
                            } catch {
                                return "检查合并状态失败: \(error.localizedDescription)"
                            }
                        })
                        VDemoButtonWithLog("获取合并状态信息", action: {
                            do {
                                let status = try ShellGit.mergeStatus(at: repoPath)
                                return "合并状态: \(status)"
                            } catch {
                                return "获取合并状态失败: \(error.localizedDescription)"
                            }
                        })
                        VDemoButtonWithLog("获取冲突文件", action: {
                            do {
                                let conflictFiles = try ShellGit.mergeConflictFiles(at: repoPath)
                                return conflictFiles.isEmpty ? "无冲突文件" : "冲突文件: \(conflictFiles.joined(separator: ", "))"
                            } catch {
                                return "获取冲突文件失败: \(error.localizedDescription)"
                            }
                        })
                    }
                    
                    VDemoSection(title: "合并控制", icon: "⚡") {
                        VDemoButtonWithLog("中止合并", action: {
                            do {
                                let result = try ShellGit.mergeAbort(at: repoPath)
                                return "中止合并结果: \(result)"
                            } catch {
                                return "中止合并失败: \(error.localizedDescription)"
                            }
                        })
                        VDemoButtonWithLog("继续合并", action: {
                            do {
                                let result = try ShellGit.mergeContinue(at: repoPath)
                                return "继续合并结果: \(result)"
                            } catch {
                                return "继续合并失败: \(error.localizedDescription)"
                            }
                        })
                    }
                    
                    VDemoSection(title: "冲突解决", icon: "🔧") {
                        VDemoButtonWithLog("使用我们的版本", action: {
                            do {
                                let result = try ShellGit.mergeResolveOurs(at: repoPath)
                                return "使用我们的版本结果: \(result)"
                            } catch {
                                return "使用我们的版本失败: \(error.localizedDescription)"
                            }
                        })
                        VDemoButtonWithLog("使用他们的版本", action: {
                            do {
                                let result = try ShellGit.mergeResolveTheirs(at: repoPath)
                                return "使用他们的版本结果: \(result)"
                            } catch {
                                return "使用他们的版本失败: \(error.localizedDescription)"
                            }
                        })
                        VDemoButtonWithLog("解决特定文件冲突（ours）", action: {
                            do {
                                let result = try ShellGit.mergeResolveOurs(["README.md"], at: repoPath)
                                return "解决 README.md 冲突（ours）结果: \(result)"
                            } catch {
                                return "解决特定文件冲突失败: \(error.localizedDescription)"
                            }
                        })
                        VDemoButtonWithLog("解决特定文件冲突（theirs）", action: {
                            do {
                                let result = try ShellGit.mergeResolveTheirs(["README.md"], at: repoPath)
                                return "解决 README.md 冲突（theirs）结果: \(result)"
                            } catch {
                                return "解决特定文件冲突失败: \(error.localizedDescription)"
                            }
                        })
                    }
                }
                .padding()
            }
        }
    }
}

// MARK: - Preview

#Preview("ShellGit+Merge Demo") {
    ShellGitMergePreview()
        
}

#endif
