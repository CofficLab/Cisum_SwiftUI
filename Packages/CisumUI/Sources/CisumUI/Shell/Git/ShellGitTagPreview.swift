#if DEBUG && os(macOS)
import SwiftUI

struct ShellGitTagPreview: View {
    var body: some View {
        ShellGitExampleRepoView { repoPath in
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    VDemoSection(title: "标签管理", icon: "🏷️") {
                        VDemoButtonWithLog("获取标签列表", action: {
                            do {
                                let tags = try ShellGit.tags(at: repoPath)
                                return tags.isEmpty ? "无标签" : tags
                            } catch {
                                return "获取标签列表失败: \(error.localizedDescription)"
                            }
                        })
                        VDemoButtonWithLog("创建标签", action: {
                            do {
                                let result = try ShellGit.createTag("test-tag", message: "测试标签", at: repoPath)
                                return "创建标签结果: \(result)"
                            } catch {
                                return "创建标签失败: \(error.localizedDescription)"
                            }
                        })
                        VDemoButtonWithLog("删除标签", action: {
                            do {
                                let result = try ShellGit.deleteTag("test-tag", at: repoPath)
                                return "删除标签结果: \(result)"
                            } catch {
                                return "删除标签失败: \(error.localizedDescription)"
                            }
                        })
                        VDemoButtonWithLog("标签结构体列表", action: {
                            do {
                                let tags = try ShellGit.tagList(at: repoPath)
                                return tags.isEmpty ? "无标签" : tags.map { "\($0.name): \($0.commitHash)" }.joined(separator: ", ")
                            } catch {
                                return "获取标签结构体失败: \(error.localizedDescription)"
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

#Preview("ShellGit+Tag Demo") {
    ShellGitTagPreview()
        
}

#endif
