#if DEBUG && os(macOS)
import SwiftUI

struct ShellFilePreviewView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("🐚 ShellFile 功能演示")
                .font(.title)
                .bold()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    VDemoSection(title: "文件操作", icon: "📁") {
                        VDemoButtonWithLog("检查目录存在", action: {
                            let shell = ShellFile()
                            let exists = shell.isDirExists("/tmp")
                            return "目录 /tmp 存在: \(exists)"
                        })
                        
                        VDemoButtonWithLog("创建测试目录", action: {
                            let shell = ShellFile()
                            shell.makeDir("/tmp/test_dir", verbose: true)
                            return "已尝试创建 /tmp/test_dir"
                        })
                        
                        VDemoButtonWithLog("创建测试文件", action: {
                            let shell = ShellFile()
                            shell.makeFile("/tmp/test_file.txt", content: "Hello, World!")
                            return "已尝试创建 /tmp/test_file.txt"
                        })
                    }
                    
                    VDemoSection(title: "文件信息", icon: "ℹ️") {
                        VDemoButtonWithLog("获取文件大小", action: {
                            let shell = ShellFile()
                            do {
                                let size = try shell.getFileSize("/tmp/test_file.txt")
                                return "文件大小: \(size) 字节"
                            } catch {
                                return "获取文件大小失败: \(error.localizedDescription)"
                            }
                        })
                        
                        VDemoButtonWithLog("获取文件权限", action: {
                            let shell = ShellFile()
                            do {
                                let permissions = try shell.getPermissions("/tmp/test_file.txt")
                                return "文件权限: \(permissions)"
                            } catch {
                                return "获取文件权限失败: \(error.localizedDescription)"
                            }
                        })
                    }
                    
                    VDemoSection(title: "目录操作", icon: "📂") {
                        VDemoButtonWithLog("列出文件", action: {
                            let shell = ShellFile()
                            do {
                                let files = try shell.listFiles("/tmp")
                                return "文件列表:\n\(files.joined(separator: "\n"))"
                            } catch {
                                return "列出文件失败: \(error.localizedDescription)"
                            }
                        })
                    }
                }
                .padding()
            }
        }
        .padding()
    }
}

#Preview("ShellFile Demo") {
    ShellFilePreviewView()
}

#endif
