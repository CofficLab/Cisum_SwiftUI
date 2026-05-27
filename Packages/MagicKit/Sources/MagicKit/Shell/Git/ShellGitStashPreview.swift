#if DEBUG && os(macOS)

import SwiftUI

struct ShellGitStashPreview: View {
    var body: some View {
        ShellGitExampleRepoView { repoPath in
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    VDemoSection(title: "暂存操作", icon: "📦") {
                        VDemoButtonWithLog("暂存更改", action: {
                            do {
                                let result = try ShellGit.stash("测试暂存", at: repoPath)
                                return "暂存结果: \(result)"
                            } catch {
                                return "暂存失败: \(error.localizedDescription)"
                            }
                        })
                        VDemoButtonWithLog("恢复最新暂存", action: {
                            do {
                                let result = try ShellGit.stashPop(at: repoPath)
                                return "恢复结果: \(result)"
                            } catch {
                                return "恢复失败: \(error.localizedDescription)"
                            }
                        })
                        VDemoButtonWithLog("获取暂存列表", action: {
                            do {
                                let list = try ShellGit.stashList(at: repoPath)
                                return list.isEmpty ? "无暂存" : list
                            } catch {
                                return "获取暂存列表失败: \(error.localizedDescription)"
                            }
                        })
                        VDemoButtonWithLog("暂存结构体列表", action: {
                            do {
                                let stashes = try ShellGit.stashListArray(at: repoPath)
                                return stashes.isEmpty ? "无暂存" : stashes.map { "#\($0.id): \($0.description)" }.joined(separator: "\n")
                            } catch {
                                return "获取暂存结构体失败: \(error.localizedDescription)"
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

#Preview("ShellGit+Stash Demo") {
    ShellGitStashPreview()
        
} 
#endif
