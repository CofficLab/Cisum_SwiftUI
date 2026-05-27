#if DEBUG && os(macOS)
    import SwiftUI

    struct ShellGitClonePreview: View {
        @State private var testRepoURL = "https://github.com/apple/swift-collections.git"
        @State private var cloneResult: String = ""
        @State private var error: String?
        @State private var isCloning: Bool = false

        var body: some View {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Git Clone 操作演示")
                        .font(.title2)
                        .fontWeight(.bold)

                    TextField("仓库 URL", text: $testRepoURL)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    if let error = error {
                        Text(error)
                            .foregroundColor(.red)
                            .padding(.vertical, 4)
                    }

                    if isCloning {
                        ProgressView("正在克隆...")
                            .padding(.vertical, 4)
                    }

                    if !cloneResult.isEmpty {
                        ScrollView {
                            Text(cloneResult)
                                .font(.system(.body, design: .monospaced))
                                .padding()
                                .background(Color.secondary.opacity(0.1))
                                .cornerRadius(8)
                        }
                        .frame(maxHeight: 200)
                    }
                }

                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        VDemoSection(title: "基础克隆操作", icon: "📦") {
                            VDemoButtonWithLog("完整克隆", action: {
                                let tempDir = createTempDirectory()
                                do {
                                    let result = try ShellGit.clone(testRepoURL, to: tempDir)
                                    return "克隆成功到: \(tempDir)\n结果: \(result)"
                                } catch {
                                    return "克隆失败: \(error.localizedDescription)"
                                }
                            })

                            VDemoButtonWithLog("浅克隆 (深度=1)", action: {
                                let tempDir = createTempDirectory()
                                do {
                                    let result = try ShellGit.shallowClone(testRepoURL, to: tempDir)
                                    return "浅克隆成功到: \(tempDir)\n结果: \(result)"
                                } catch {
                                    return "浅克隆失败: \(error.localizedDescription)"
                                }
                            })

                            VDemoButtonWithLog("克隆指定分支", action: {
                                let tempDir = createTempDirectory()
                                do {
                                    let result = try ShellGit.cloneBranch(testRepoURL, branch: "main", to: tempDir)
                                    return "克隆 main 分支成功到: \(tempDir)\n结果: \(result)"
                                } catch {
                                    return "克隆分支失败: \(error.localizedDescription)"
                                }
                            })
                        }

                        VDemoSection(title: "高级克隆操作", icon: "⚙️") {
                            VDemoButtonWithLog("递归克隆（含子模块）", action: {
                                let tempDir = createTempDirectory()
                                do {
                                    let result = try ShellGit.cloneRecursive(testRepoURL, to: tempDir)
                                    return "递归克隆成功到: \(tempDir)\n结果: \(result)"
                                } catch {
                                    return "递归克隆失败: \(error.localizedDescription)"
                                }
                            })

                            VDemoButtonWithLog("裸克隆", action: {
                                let tempDir = createTempDirectory()
                                do {
                                    let result = try ShellGit.cloneBare(testRepoURL, to: tempDir)
                                    return "裸克隆成功到: \(tempDir)\n结果: \(result)"
                                } catch {
                                    return "裸克隆失败: \(error.localizedDescription)"
                                }
                            })

                            VDemoButtonWithLog("镜像克隆", action: {
                                let tempDir = createTempDirectory()
                                do {
                                    let result = try ShellGit.cloneMirror(testRepoURL, to: tempDir)
                                    return "镜像克隆成功到: \(tempDir)\n结果: \(result)"
                                } catch {
                                    return "镜像克隆失败: \(error.localizedDescription)"
                                }
                            })
                        }

                        VDemoSection(title: "工具方法", icon: "🔧") {
                            VDemoButtonWithLog("检查仓库URL有效性", action: {
                                let isValid = ShellGit.isValidGitRepository(testRepoURL)
                                return "仓库 URL \(testRepoURL) \(isValid ? "有效" : "无效")"
                            })

                            VDemoButtonWithLog("克隆并获取路径", action: {
                                let tempDir = createTempDirectory()
                                do {
                                    let (result, repoPath) = try ShellGit.cloneAndGetPath(testRepoURL, to: tempDir)
                                    return "克隆成功\n结果: \(result)\n仓库路径: \(repoPath)"
                                } catch {
                                    return "克隆并获取路径失败: \(error.localizedDescription)"
                                }
                            })
                        }
                    }
                    .padding()
                }
            }
            .padding()
        }

        private func createTempDirectory() -> String {
            let tempDir = NSTemporaryDirectory()
            let uniqueDir = tempDir.appending("GitCloneTest_\(UUID().uuidString)")
            return uniqueDir
        }
    }

    #Preview("ShellGit+Clone Demo") {
        ShellGitClonePreview()
    }

#endif
