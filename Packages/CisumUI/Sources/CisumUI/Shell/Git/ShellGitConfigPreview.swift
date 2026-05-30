#if DEBUG && os(macOS)
    import SwiftUI

    struct ShellGitConfigInfoPreview: View {
        var body: some View {
            ShellGitExampleRepoView { repoPath in
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        VDemoSection(title: "仓库信息", icon: "📁") {
                            VDemoButtonWithLog("检查是否为Git仓库", action: {
                                let isRepo = ShellGit.isGitRepository(at: repoPath)
                                return "是否为Git仓库: \(isRepo)"
                            })
                            VDemoButtonWithLog("获取仓库根目录", action: {
                                do {
                                    let root = try ShellGit.repositoryRoot(at: repoPath)
                                    return "仓库根目录: \(root)"
                                } catch {
                                    return "获取仓库根目录失败: \(error.localizedDescription)"
                                }
                            })
                            VDemoButtonWithLog("获取最新提交哈希", action: {
                                do {
                                    let hash = try ShellGit.lastCommitHash(short: true, at: repoPath)
                                    return "最新提交哈希: \(hash)"
                                } catch {
                                    return "获取提交哈希失败: \(error.localizedDescription)"
                                }
                            })
                        }
                        VDemoSection(title: "用户配置", icon: "👤") {
                            VDemoButtonWithLog("获取用户配置", action: {
                                do {
                                    let config = try ShellGit.getUserConfig(global: true, at: repoPath)
                                    return "全局用户配置:\n用户名: \(config.name)\n邮箱: \(config.email)"
                                } catch {
                                    return "获取用户配置失败: \(error.localizedDescription)"
                                }
                            })
                            VDemoButtonWithLog("获取本地用户名", action: {
                                do {
                                    let name = try ShellGit.userName(at: repoPath)
                                    return "本地用户名: \(name)"
                                } catch {
                                    return "获取本地用户名失败: \(error.localizedDescription)"
                                }
                            })
                            VDemoButtonWithLog("获取本地邮箱", action: {
                                do {
                                    let email = try ShellGit.userEmail(at: repoPath)
                                    return "本地邮箱: \(email)"
                                } catch {
                                    return "获取本地邮箱失败: \(error.localizedDescription)"
                                }
                            })
                            VDemoButtonWithLog("获取全局用户名", action: {
                                do {
                                    let name = try ShellGit.userName(global: true, at: repoPath)
                                    return "全局用户名: \(name)"
                                } catch {
                                    return "获取全局用户名失败: \(error.localizedDescription)"
                                }
                            })
                            VDemoButtonWithLog("获取全局邮箱", action: {
                                do {
                                    let email = try ShellGit.userEmail(global: true, at: repoPath)
                                    return "全局邮箱: \(email)"
                                } catch {
                                    return "获取全局邮箱失败: \(error.localizedDescription)"
                                }
                            })
                            VDemoButtonWithLog("配置用户信息", action: {
                                do {
                                    let result = try ShellGit.configUser(name: "TestUser", email: "test@example.com", global: true, at: repoPath)
                                    return "配置结果: \(result)"
                                } catch {
                                    return "配置失败: \(error.localizedDescription)"
                                }
                            })
                        }
                    }
                    .padding()
                }
            }
        }
    }

    #Preview("ShellGit+ConfigInfo Demo") {
        ShellGitConfigInfoPreview()
    }

#endif
