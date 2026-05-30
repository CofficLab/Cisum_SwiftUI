import SwiftUI

#if os(macOS)
    struct ShellGitExampleRepoView<Content: View>: View {
        @State private var repoPath: String? = nil
        @State private var isLoading: Bool = true
        @State private var errorMessage: String? = nil

        private let repoURL = "https://github.com/apple/swift-collections"
        private let tempDirName = "MagicKitExampleRepo"
        let content: (String) -> Content

        private func prepareRepoIfNeeded(completion: @escaping (String?) -> Void) {
            let tempDir = NSTemporaryDirectory().appending(tempDirName)
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: tempDir + "/.git") {
                completion(tempDir)
                return
            }
            DispatchQueue.global().async {
                do {
                    if fileManager.fileExists(atPath: tempDir) {
                        try fileManager.removeItem(atPath: tempDir)
                    }
                    _ = try ShellGit.clone(self.repoURL, to: tempDir)
                    // 设置无效的本地用户信息，防止使用全局信息
                    _ = try? ShellGit.configUser(name: "invalid-user", email: "invalid@example.com", global: false, at: tempDir)
                    DispatchQueue.main.async { completion(tempDir) }
                } catch {
                    DispatchQueue.main.async {
                        self.errorMessage = "Clone 失败: \(error.localizedDescription)"
                        completion(nil)
                    }
                }
            }
        }

        private func ensureRepo() {
            isLoading = true
            errorMessage = nil
            prepareRepoIfNeeded { path in
                self.repoPath = path
                self.isLoading = false
            }
        }

        var body: some View {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("示例仓库信息")
                        .font(.headline)
                    Text("远程地址: \(repoURL)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    if let repoPath = repoPath {
                        Text("本地目录: \(repoPath)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 4)
                if isLoading {
                    ProgressView("正在准备演示仓库...")
                        .onAppear { ensureRepo() }
                } else if let error = errorMessage {
                    Text(error).foregroundColor(.red)
                    Button("重试") { ensureRepo() }
                } else if let repoPath = repoPath {
                    content(repoPath)
                }
            }
            .padding()
        }
    }
#endif
