#if DEBUG && os(macOS)
import SwiftUI

struct ShellGitDiffPreview: View {
    @State private var fileName: String = "README.md"
    @State private var headContent: String = ""
    @State private var workContent: String = ""
    @State private var error: String? = nil
    @State private var showResult: Bool = false
    @State private var diffCommit: String = "HEAD~1"
    @State private var diffFile: String = "README.md"
    @State private var beforeContent: String = ""
    @State private var afterContent: String = ""
    @State private var diffError: String? = nil
    @State private var showDiffResult: Bool = false
    @State private var filesCommit: String = "HEAD~1"
    @State private var filesList: [String] = []
    @State private var filesError: String? = nil
    @State private var showFilesResult: Bool = false
    @State private var filesDetailCommit: String = "HEAD~1"
    @State private var filesDetailList: [MagicGitDiffFile] = []
    @State private var filesDetailError: String? = nil
    @State private var showFilesDetailResult: Bool = false

    var body: some View {
        ShellGitExampleRepoView { repoPath in
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    VDemoSection(title: "差异对比", icon: "📄") {
                        VDemoButtonWithLog("获取工作区差异", action: {
                            do {
                                let diff = try ShellGit.diff(at: repoPath)
                                return diff.isEmpty ? "无差异" : diff
                            } catch {
                                return "获取差异失败: \(error.localizedDescription)"
                            }
                        })
                        VDemoButtonWithLog("获取暂存区差异", action: {
                            do {
                                let diff = try ShellGit.diff(staged: true, at: repoPath)
                                return diff.isEmpty ? "无暂存区差异" : diff
                            } catch {
                                return "获取暂存区差异失败: \(error.localizedDescription)"
                            }
                        })
                        VDemoButtonWithLog("检查是否有文件待提交", action: {
                            do {
                                let hasFiles = try ShellGit.hasFilesToCommit(at: repoPath)
                                return hasFiles ? "有文件待提交" : "无文件待提交"
                            } catch {
                                return "检查失败: \(error.localizedDescription)"
                            }
                        })
                    }
                    VDemoSection(title: "文件内容对比", icon: "📝") {
                        HStack {
                            TextField("文件名（相对路径）", text: $fileName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Button("对比") {
                                do {
                                    headContent = try ShellGit.fileContent(atCommit: "HEAD", file: fileName, at: repoPath)
                                    workContent = try ShellGit.fileContentInWorkingDirectory(file: fileName, at: repoPath)
                                    error = nil
                                    showResult = true
                                } catch let e {
                                    error = e.localizedDescription
                                    showResult = false
                                }
                            }
                        }
                        if let error = error {
                            Text("错误: \(error)").foregroundColor(.red)
                        }
                        if showResult {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("HEAD 内容:")
                                    .font(.caption)
                                ScrollView {
                                    Text(headContent)
                                        .font(.system(size: 12, design: .monospaced))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }.frame(maxHeight: 120)
                                    .background(Color.green.opacity(0.4))
                                Text("工作区内容:")
                                    .font(.caption)
                                ScrollView {
                                    Text(workContent)
                                        .font(.system(size: 12, design: .monospaced))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }.frame(maxHeight: 120)
                                    .background(Color.gray.opacity(0.4))
                            }
                            .padding(6)
                            .cornerRadius(8)
                        }
                    }
                    VDemoSection(title: "指定 commit 文件变动内容", icon: "🔍") {
                        HStack {
                            TextField("commit 哈希", text: $diffCommit)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            TextField("文件名（相对路径）", text: $diffFile)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Button("获取") {
                                do {
                                    let (before, after) = try ShellGit.fileContentChange(at: diffCommit, file: diffFile, repoPath: repoPath)
                                    beforeContent = before ?? "(文件不存在)"
                                    afterContent = after ?? "(文件不存在)"
                                    diffError = nil
                                    showDiffResult = true
                                } catch let e {
                                    diffError = e.localizedDescription
                                    showDiffResult = false
                                }
                            }
                        }
                        if let diffError = diffError {
                            Text("错误: \(diffError)").foregroundColor(.red)
                        }
                        if showDiffResult {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("修改前内容:")
                                    .font(.caption)
                                ScrollView {
                                    Text(beforeContent)
                                        .font(.system(size: 12, design: .monospaced))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }.frame(maxHeight: 120)
                                    .background(Color.yellow.opacity(0.3))
                                Text("修改后内容:")
                                    .font(.caption)
                                ScrollView {
                                    Text(afterContent)
                                        .font(.system(size: 12, design: .monospaced))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }.frame(maxHeight: 120)
                                    .background(Color.blue.opacity(0.2))
                            }
                            .padding(6)
                            .cornerRadius(8)
                        }
                    }
                    VDemoSection(title: "指定 commit 变动文件列表", icon: "📂") {
                        HStack {
                            TextField("commit 哈希", text: $filesCommit)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Button("获取") {
                                do {
                                    filesList = try ShellGit.changedFiles(in: filesCommit, at: repoPath)
                                    filesError = nil
                                    showFilesResult = true
                                } catch let e {
                                    filesError = e.localizedDescription
                                    showFilesResult = false
                                }
                            }
                        }
                        if let filesError = filesError {
                            Text("错误: \(filesError)").foregroundColor(.red)
                        }
                        if showFilesResult {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("变动文件列表:")
                                    .font(.caption)
                                if filesList.isEmpty {
                                    Text("无变动文件")
                                        .foregroundColor(.secondary)
                                } else {
                                    ForEach(filesList, id: \.self) { file in
                                        Text(file)
                                            .font(.system(size: 13, design: .monospaced))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                            }
                            .padding(6)
                            .cornerRadius(8)
                        }
                    }
                }
                .padding()
            }
        }
    }
}

// MARK: - Preview

#Preview("ShellGit+Diff Demo") {
    ShellGitDiffPreview()
        
}

#endif
