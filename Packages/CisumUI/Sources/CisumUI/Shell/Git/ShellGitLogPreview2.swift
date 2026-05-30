#if DEBUG && os(macOS)
import SwiftUI

    struct ShellGitLogPreview2: View {
        @State private var repoPath: String? = nil
        @State private var isLoading: Bool = true
        @State private var errorMessage: String? = nil
        
        @State private var logPage: Int = 0
        @State private var logSize: Int = 10
        @State private var pagedLogs: [String] = []
        @State private var pagedError: String? = nil

        var body: some View {
            VStack {
                if isLoading {
                    ProgressView("正在创建临时项目并初始化 Git...")
                        .onAppear {
                            prepareCustomRepo()
                        }
                } else if let error = errorMessage {
                    VStack {
                        Text("创建失败: \(error)")
                            .foregroundColor(.red)
                        Button("重试") {
                            prepareCustomRepo()
                        }
                    }
                } else if let path = repoPath {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 15) {
                            VDemoSection(title: "仓库信息", icon: "📁") {
                                Text("临时目录: \(path)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            
                            VDemoSection(title: "提交日志", icon: "📝") {
                                VDemoButtonWithLog("获取所有提交日志", action: {
                                    do {
                                        let log = try ShellGit.log(limit: 10, at: path)
                                        return log
                                    } catch {
                                        return "获取失败: \(error.localizedDescription)"
                                    }
                                })
                                
                                VDemoButtonWithLog("获取 MagicGitCommit 列表", action: {
                                    do {
                                        let commits = try ShellGit.commitList(limit: 10, at: path)
                                        let df = DateFormatter()
                                        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                        return commits.map { c in
                                            "\(c.hash.prefix(7)) | \(c.author) | \(df.string(from: c.date))\n  \(c.message)"
                                        }.joined(separator: "\n\n")
                                    } catch {
                                        return "获取失败: \(error.localizedDescription)"
                                    }
                                })
                            }
                            
                            VDemoSection(title: "分页获取", icon: "📄") {
                                HStack(spacing: 10) {
                                    Button("上一页") {
                                        if logPage > 0 { logPage -= 1 }
                                        loadPagedLogs(path)
                                    }
                                    Button("下一页") {
                                        logPage += 1
                                        loadPagedLogs(path)
                                    }
                                    Text("第 \(logPage) 页")
                                }
                                .padding(.bottom, 4)
                                
                                if !pagedLogs.isEmpty {
                                    VStack(alignment: .leading, spacing: 2) {
                                        ForEach(pagedLogs, id: \.self) { log in
                                            Text(log)
                                                .font(.system(size: 12, design: .monospaced))
                                        }
                                    }
                                    .padding(6)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .frame(width: 600, height: 800)
        }

        private func prepareCustomRepo() {
            isLoading = true
            errorMessage = nil
            
            DispatchQueue.global().async {
                do {
                    let tempDir = NSTemporaryDirectory().appending("MagicKit_CustomRepo_\(UUID().uuidString.prefix(8))")
                    let fileManager = FileManager.default
                    
                    // 1. 创建目录
                    try fileManager.createDirectory(atPath: tempDir, withIntermediateDirectories: true)
                    
                    // 2. 初始化 Git
                    _ = try ShellGit.initRepository(at: tempDir)
                    
                    // 3. 配置本地用户 (必须配置，否则 commit 会失败)
                    _ = try ShellGit.configUser(name: "Demo User", email: "demo@example.com", global: false, at: tempDir)
                    
                    // 4. 第一个 commit
                    let file1 = tempDir + "/README.md"
                    try "# Hello Git".write(toFile: file1, atomically: true, encoding: .utf8)
                    try ShellGit.addAndCommit(files: ["README.md"], message: "Initial commit: Add README", at: tempDir)
                    
                    // 5. 第二个 commit
                    let file2 = tempDir + "/main.swift"
                    try "print(\"Hello, World!\")".write(toFile: file2, atomically: true, encoding: .utf8)
                    try ShellGit.addAndCommit(files: ["main.swift"], message: "Second commit: Add main.swift", at: tempDir)
                    
                    DispatchQueue.main.async {
                        self.repoPath = tempDir
                        self.isLoading = false
                        loadPagedLogs(tempDir)
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.errorMessage = error.localizedDescription
                        self.isLoading = false
                    }
                }
            }
        }
        
        private func loadPagedLogs(_ path: String) {
            do {
                pagedLogs = try ShellGit.logsWithPagination(page: logPage, size: logSize, at: path)
                pagedError = nil
            } catch {
                pagedLogs = []
                pagedError = error.localizedDescription
            }
        }
    }

    #Preview("ShellGitLogPreview") {
        ShellGitLogPreview()
    }

    #Preview("ShellGitLogPreview2") {
        ShellGitLogPreview2()
    }

#endif
