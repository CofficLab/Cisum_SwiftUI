#if DEBUG && os(macOS)
import SwiftUI

struct ShellGitCorePreview: View {
    var body: some View {
        ShellGitExampleRepoView { repoPath in
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    VDemoSection(title: "仓库操作", icon: "🔧") {
                        VDemoButtonWithLog("初始化仓库", action: {
                            do {
                                let result = try ShellGit.initRepository(at: repoPath)
                                return "初始化结果: \(result)"
                            } catch {
                                return "初始化失败: \(error.localizedDescription)"
                            }
                        })
                    }
                }
                .padding()
            }
        }
    }
}

#Preview("ShellGit+Core Demo") {
    ShellGitCorePreview()
        
}
#endif
