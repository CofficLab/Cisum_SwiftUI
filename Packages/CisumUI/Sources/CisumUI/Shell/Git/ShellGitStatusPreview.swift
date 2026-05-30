#if DEBUG && os(macOS)
import SwiftUI

struct ShellGitStatusPreview: View {
    var body: some View {
        ShellGitExampleRepoView { repoPath in
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    VDemoSection(title: "暂存区操作", icon: "📥") {
                        VDemoButtonWithLog("添加所有文件到暂存区", action: {
                            do {
                                try ShellGit.add([], at: repoPath)
                                return "添加成功"
                            } catch {
                                return "添加失败: \(error.localizedDescription)"
                            }
                        })
                        VDemoButtonWithLog("提交更改", action: {
                            do {
                                let result = try ShellGit.commit(message: "测试提交", at: repoPath)
                                return "提交结果: \(result)"
                            } catch {
                                return "提交失败: \(error.localizedDescription)"
                            }
                        })
                        VDemoButtonWithLog("获取仓库状态", action: {
                            do {
                                let status = try ShellGit.status(at: repoPath)
                                return status.isEmpty ? "工作区干净" : status
                            } catch {
                                return "获取状态失败: \(error.localizedDescription)"
                            }
                        })
                        VDemoButtonWithLog("获取详细状态", action: {
                            do {
                                let status = try ShellGit.statusPorcelain(at: repoPath)
                                return status.isEmpty ? "无详细状态" : status
                            } catch {
                                return "获取详细状态失败: \(error.localizedDescription)"
                            }
                        })
                        VDemoButtonWithLog("是否有未提交变动", action: {
                            do {
                                let hasChanges = try ShellGit.hasUncommittedChanges(at: repoPath)
                                return hasChanges ? "有未提交变动" : "无未提交变动"
                            } catch {
                                return "检测失败: \(error.localizedDescription)"
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

#Preview("ShellGit+Staging Demo") {
    ShellGitStatusPreview()
        
} 
#endif

