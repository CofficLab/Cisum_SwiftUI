#if DEBUG
import SwiftUI
#if os(macOS)
struct ShellProcessPreviewView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("⚙️ ShellProcess 功能演示")
                .font(Font.title)
                .bold()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    VDemoSection(title: "进程查找", icon: "🔍") {
                        VDemoButtonWithLog("查找Finder进程", action: {
                            let processes = ShellProcess.findProcesses(named: "Finder")
                            let prefixProcesses = processes.prefix(3).map { "PID: \($0.pid), CPU: \($0.cpu)%, 内存: \($0.memory)%" }.joined(separator: "\n")
                            return "找到 \(processes.count) 个Finder进程\n" + prefixProcesses
                        })
                        
                        VDemoButtonWithLog("检查Chrome是否运行", action: {
                            let isRunning = ShellProcess.isProcessRunning("Chrome")
                            let message = isRunning ? "是" : "否"
                            return "Chrome是否运行: \(message)"
                        })
                        
                        VDemoButtonWithLog("获取正在运行的应用", action: {
                            let apps = ShellProcess.getRunningApps()
                            return "正在运行的应用: \(apps.prefix(5).joined(separator: ", "))"
                        })
                    }
                    
                    VDemoSection(title: "系统资源", icon: "📊") {
                        VDemoButtonWithLog("系统负载", action: {
                            let load = ShellProcess.getSystemLoad()
                            return "系统负载: \(load)"
                        })
                        
                        VDemoButtonWithLog("内存使用情况", action: {
                            let memory = ShellProcess.getMemoryUsage()
                            let lines = memory.components(separatedBy: .newlines)
                            return "内存使用情况（前5行）:\n\(lines.prefix(5).joined(separator: "\n"))"
                        })
                    }
                    
                    VDemoSection(title: "TOP进程", icon: "🏆") {
                        VDemoButtonWithLog("CPU使用率最高的进程", action: {
                            let processes = ShellProcess.getTopCPUProcesses(count: 5)
                            let formattedProcesses = processes.map { "\($0.command.prefix(30)) - CPU: \($0.cpu)%" }.joined(separator: "\n")
                            return "CPU使用率最高的5个进程:\n" + formattedProcesses
                        })
                        
                        VDemoButtonWithLog("内存使用率最高的进程", action: {
                            let processes = ShellProcess.getTopMemoryProcesses(count: 5)
                            let formattedProcesses = processes.map { "\($0.command.prefix(30)) - 内存: \($0.memory)%" }.joined(separator: "\n")
                            return "内存使用率最高的5个进程:\n" + formattedProcesses
                        })
                    }
                    
                    VDemoSection(title: "应用程序管理", icon: "📱") {
                        VDemoButtonWithLog("启动计算器", action: {
                            do {
                                try ShellProcess.launchApp("Calculator")
                                return "计算器已启动"
                            } catch {
                                return "启动计算器失败: \(error.localizedDescription)"
                            }
                        })
                        
                        VDemoButtonWithLog("启动文本编辑器", action: {
                            do {
                                try ShellProcess.launchApp("TextEdit")
                                return "文本编辑器已启动"
                            } catch {
                                return "启动文本编辑器失败: \(error.localizedDescription)"
                            }
                        })
                    }
                    
                    VDemoSection(title: "进程详情", icon: "🔬") {
                        VProcessDetailView()
                    }
                    
                    VDemoSection(title: "系统服务", icon: "🛠️") {
                        VDemoButtonWithLog("查看系统服务", action: {
                            let services = ShellProcess.getSystemServices()
                            let lines = services.components(separatedBy: .newlines)
                            return "系统服务（前10个）:\n\(lines.prefix(10).joined(separator: "\n"))"
                        })
                    }
                    
                    VDemoSection(title: "危险操作", icon: "⚠️") {
                        Text("注意：以下操作可能影响系统稳定性")
                            .font(.caption)
                            .foregroundColor(.red)
                        
                        VDemoButtonWithLog("杀死测试进程（安全）", action: {
                            // 这里只是演示，不会真的杀死重要进程
                            return "这是一个安全的演示，不会真的杀死进程\n实际使用时请谨慎操作"
                        })
                    }
                }
                .padding()
            }
        }
        .padding()
    }
}

#if DEBUG
#Preview("ShellProcess Demo") {
    ShellProcessPreviewView()
        
}
#endif
#endif

#endif
