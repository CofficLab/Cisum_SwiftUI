#if DEBUG && os(macOS)
    import SwiftUI

    struct ShellGitBranchPreview: View {
        var body: some View {
            ShellGitExampleRepoView { repoPath in
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        VDemoSection(title: "分支操作", icon: "🌿") {
                            VDemoButtonWithLog("获取分支列表", action: {
                                do {
                                    let branches = try ShellGit.branches(at: repoPath)
                                    return "分支列表:\n\(branches)"
                                } catch {
                                    return "获取分支列表失败: \(error.localizedDescription)"
                                }
                            })
                            VDemoButtonWithLog("获取分支数组", action: {
                                do {
                                    let branches = try ShellGit.branchesArray(at: repoPath)
                                    return branches.isEmpty ? "无分支" : branches.joined(separator: ", ")
                                } catch {
                                    return "获取分支数组失败: \(error.localizedDescription)"
                                }
                            })
                            VDemoButtonWithLog("获取当前分支", action: {
                                do {
                                    let branch = try ShellGit.currentBranch(at: repoPath)
                                    return "当前分支: \(branch)"
                                } catch {
                                    return "获取当前分支失败: \(error.localizedDescription)"
                                }
                            })
                            VDemoButtonWithLog("创建新分支", action: {
                                do {
                                    let result = try ShellGit.createBranch("test-branch", at: repoPath)
                                    return "创建分支结果: \(result)"
                                } catch {
                                    return "创建分支失败: \(error.localizedDescription)"
                                }
                            })
                            VDemoButtonWithLog("切换分支", action: {
                                do {
                                    let result = try ShellGit.checkout("test-branch", at: repoPath)
                                    return "切换分支结果: \(result)"
                                } catch {
                                    return "切换分支失败: \(error.localizedDescription)"
                                }
                            })
                            VDemoButtonWithLog("删除分支", action: {
                                do {
                                    let result = try ShellGit.deleteBranch("test-branch", force: true, at: repoPath)
                                    return "删除分支结果: \(result)"
                                } catch {
                                    return "删除分支失败: \(error.localizedDescription)"
                                }
                            })
                            VDemoButtonWithLog("合并分支", action: {
                                do {
                                    let result = try ShellGit.merge("main", at: repoPath)
                                    return "合并结果: \(result)"
                                } catch {
                                    return "合并失败: \(error.localizedDescription)"
                                }
                            })
                            VDemoButtonWithLog("分支结构体列表", action: {
                                do {
                                    let branches = try ShellGit.branchList(at: repoPath)
                                    return branches.isEmpty ? "无分支" : branches.map { "\($0.name)\($0.isCurrent ? "（当前）" : "")" }.joined(separator: ", ")
                                } catch {
                                    return "获取分支结构体失败: \(error.localizedDescription)"
                                }
                            })
                        }
                    }
                    .padding()
                }
            }
        }
    }

    #Preview("ShellGit+Branch Demo") {
        ShellGitBranchPreview()
    }

#endif
