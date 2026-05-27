#if DEBUG && os(macOS)
    import SwiftUI

    struct ShellGitResetPreview: View {
        var body: some View {
            ShellGitExampleRepoView { repoPath in
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        VDemoSection(title: "重置操作", icon: "♻️") {
                            VDemoButtonWithLog("软重置所有文件", action: {
                                do {
                                    let result = try ShellGit.reset(at: repoPath)
                                    return "软重置结果: \(result)"
                                } catch {
                                    return "软重置失败: \(error.localizedDescription)"
                                }
                            })
                            VDemoButtonWithLog("硬重置所有文件", action: {
                                do {
                                    let result = try ShellGit.resetHard(at: repoPath)
                                    return "硬重置结果: \(result)"
                                } catch {
                                    return "硬重置失败: \(error.localizedDescription)"
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

    #Preview("ShellGit+Reset Demo") {
        ShellGitResetPreview()
    }

#endif
