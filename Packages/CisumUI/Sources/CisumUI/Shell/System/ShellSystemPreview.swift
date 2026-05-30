#if DEBUG
import SwiftUI
#if os(macOS)
struct ShellSystemPreviewView: View {
    
    var body: some View {
        VStack(spacing: 20) {
            Text("💻 ShellSystem 功能演示")
                .font(Font.title)
                .bold()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    VDemoSection(title: "基本信息", icon: "ℹ️") {
                        VInfoRow("当前目录", ShellSystem.pwd())
                        VInfoRow("当前用户", ShellSystem.whoami())
                        VInfoRow("系统时间", ShellSystem.systemTime())
                    }
                    
                    VDemoSection(title: "硬件信息", icon: "🖥️") {
                        VInfoRow("CPU", ShellSystem.cpuInfo())
                        VInfoRow("内存", ShellSystem.memoryInfo())
                        
                        VDemoButtonWithLog("获取系统版本", action: {
                            let version = ShellSystem.systemVersion()
                            return "系统版本:\n\(version)"
                        })
                    }
                    
                    VDemoSection(title: "系统状态", icon: "📊") {
                        VDemoButtonWithLog("系统负载", action: {
                            let load = ShellSystem.loadAverage()
                            return "系统负载: \(load)"
                        })
                        
                        VDemoButtonWithLog("磁盘使用情况", action: {
                            let disk = ShellSystem.diskUsage()
                            return "磁盘使用情况:\n\(disk)"
                        })
                        
                        VDemoButtonWithLog("启动时间", action: {
                            let bootTime = ShellSystem.bootTime()
                            return "启动时间: \(bootTime)"
                        })
                    }
                    
                    VDemoSection(title: "环境变量", icon: "🌍") {
                        VDemoButtonWithLog("PATH变量", action: {
                            let paths = ShellSystem.getPath()
                            return "PATH目录: \(paths.prefix(5).joined(separator: ":"))"
                        })
                        
                        VDemoButtonWithLog("HOME目录", action: {
                            let home = ShellSystem.getEnvironmentVariable("HOME")
                            return "HOME目录: \(home)"
                        })
                    }
                    
                    VDemoSection(title: "命令检查", icon: "🔍") {
                        VCommandCheckRow("git")
                        VCommandCheckRow("node")
                        VCommandCheckRow("python3")
                        VCommandCheckRow("docker")
                    }
                    
                    VDemoSection(title: "进程信息", icon: "⚙️") {
                        VDemoButtonWithLog("查看所有进程", action: {
                            let processes = ShellSystem.processes()
                            let lines = processes.components(separatedBy: .newlines).filter { !$0.isEmpty }
                            return "进程总数: \(lines.count)\n前5个进程:\n\(lines.prefix(5).joined(separator: "\n"))"
                        })
                        
                        VDemoButtonWithLog("查找特定进程", action: {
                            let processes = ShellSystem.processes(named: "Finder")
                            return "Finder进程:\n\(processes)"
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
#Preview("ShellSystem Demo") {
    ShellSystemPreviewView()
        
} 
#endif

#endif

#endif
