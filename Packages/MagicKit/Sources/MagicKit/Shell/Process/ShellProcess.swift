import Foundation
import OSLog
import SwiftUI

#if os(macOS)

/// 进程管理相关的Shell命令工具类
class ShellProcess: SuperLog {
    static let emoji = "⚙️"
    
    /// 进程信息结构体
    struct ProcessInfo {
        let pid: String
        let user: String
        let cpu: String
        let memory: String
        let command: String
        
        static func fromPSLine(_ line: String) -> ProcessInfo? {
            let components = line.components(separatedBy: .whitespaces)
                .filter { !$0.isEmpty }
            
            guard components.count >= 11 else { return nil }
            
            return ProcessInfo(
                pid: components[1],
                user: components[0],
                cpu: components[2],
                memory: components[3],
                command: components[10...].joined(separator: " ")
            )
        }
    }
    
    /// 获取所有进程信息
    /// - Returns: 进程信息数组
    static func getAllProcesses() -> [ProcessInfo] {
        do {
            let result = try Shell.runSync("ps aux")
            let lines = result.components(separatedBy: .newlines)
                .dropFirst() // 跳过标题行
                .filter { !$0.isEmpty }
            
            return lines.compactMap { ProcessInfo.fromPSLine($0) }
        } catch {
            return []
        }
    }
    
    /// 根据进程名查找进程
    /// - Parameter name: 进程名
    /// - Returns: 匹配的进程信息数组
    static func findProcesses(named name: String) -> [ProcessInfo] {
        do {
            let result = try Shell.runSync("ps aux | grep \"\(name)\" | grep -v grep")
            let lines = result.components(separatedBy: CharacterSet.newlines)
                .filter { !$0.isEmpty }
            
            return lines.compactMap { ProcessInfo.fromPSLine($0) }
        } catch {
            return []
        }
    }
    
    /// 根据PID查找进程
    /// - Parameter pid: 进程ID
    /// - Returns: 进程信息
    static func findProcess(pid: String) -> ProcessInfo? {
        do {
            let result = try Shell.runSync("ps aux | grep \"\\b\(pid)\\b\" | grep -v grep")
            let lines = result.components(separatedBy: CharacterSet.newlines)
                .filter { !$0.isEmpty }
            
            return lines.first.flatMap { ProcessInfo.fromPSLine($0) }
        } catch {
            return nil
        }
    }
    
    /// 杀死进程
    /// - Parameter pid: 进程ID
    /// - Throws: 杀死进程失败时抛出错误
    static func killProcess(pid: String) throws {
        try Shell.runSync("kill \(pid)")
    }
    
    /// 强制杀死进程
    /// - Parameter pid: 进程ID
    /// - Throws: 杀死进程失败时抛出错误
    static func forceKillProcess(pid: String) throws {
        try Shell.runSync("kill -9 \(pid)")
    }
    
    /// 根据进程名杀死所有匹配的进程
    /// - Parameter name: 进程名
    /// - Throws: 杀死进程失败时抛出错误
    static func killProcesses(named name: String) throws {
        try Shell.runSync("pkill \"\(name)\"")
    }
    
    /// 获取进程树
    /// - Parameter pid: 根进程ID（可选）
    /// - Returns: 进程树信息
    static func getProcessTree(pid: String? = nil) -> String {
        do {
            if let pid = pid {
                return try Shell.runSync("pstree \(pid)")
            } else {
                return try Shell.runSync("pstree")
            }
        } catch {
            return error.localizedDescription
        }
    }
    
    /// 获取系统负载信息
    /// - Returns: 系统负载信息
    static func getSystemLoad() -> String {
        do {
            return try Shell.runSync("uptime")
        } catch {
            return error.localizedDescription
        }
    }
    
    /// 获取内存使用情况
    /// - Returns: 内存使用情况
    static func getMemoryUsage() -> String {
        do {
            return try Shell.runSync("vm_stat")
        } catch {
            return error.localizedDescription
        }
    }
    
    /// 获取CPU使用率最高的进程
    /// - Parameter count: 返回的进程数量（默认10个）
    /// - Returns: CPU使用率最高的进程
    static func getTopCPUProcesses(count: Int = 10) -> [ProcessInfo] {
        do {
            let result = try Shell.runSync("ps aux --sort=-%cpu | head -\(count + 1)")
            let lines = result.components(separatedBy: .newlines)
                .dropFirst() // 跳过标题行
                .filter { !$0.isEmpty }
            
            return lines.compactMap { ProcessInfo.fromPSLine($0) }
        } catch {
            return []
        }
    }
    
    /// 获取内存使用率最高的进程
    /// - Parameter count: 返回的进程数量（默认10个）
    /// - Returns: 内存使用率最高的进程
    static func getTopMemoryProcesses(count: Int = 10) -> [ProcessInfo] {
        do {
            let result = try Shell.runSync("ps aux --sort=-%mem | head -\(count + 1)")
            let lines = result.components(separatedBy: .newlines)
                .dropFirst() // 跳过标题行
                .filter { !$0.isEmpty }
            
            return lines.compactMap { ProcessInfo.fromPSLine($0) }
        } catch {
            return []
        }
    }
    
    /// 启动应用程序
    /// - Parameter appName: 应用程序名称
    /// - Throws: 启动失败时抛出错误
    static func launchApp(_ appName: String) throws {
        try Shell.runSync("open -a \"\(appName)\"")
    }
    
    /// 启动应用程序并打开文件
    /// - Parameters:
    ///   - appName: 应用程序名称
    ///   - filePath: 文件路径
    /// - Throws: 启动失败时抛出错误
    static func launchApp(_ appName: String, withFile filePath: String) throws {
        try Shell.runSync("open -a \"\(appName)\" \"\(filePath)\"")
    }
    
    /// 获取正在运行的应用程序
    /// - Returns: 应用程序列表
    static func getRunningApps() -> [String] {
        do {
            let result = try Shell.runSync("osascript -e 'tell application \"System Events\" to get name of every process whose background only is false'")
            return result.components(separatedBy: ", ")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
        } catch {
            return []
        }
    }
    
    /// 检查进程是否正在运行
    /// - Parameter name: 进程名
    /// - Returns: 进程是否正在运行
    static func isProcessRunning(_ name: String) -> Bool {
        do {
            let result = try Shell.runSync("pgrep \"\(name)\"")
            return !result.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty
        } catch {
            return false
        }
    }
    
    /// 获取进程的详细信息
    /// - Parameter pid: 进程ID
    /// - Returns: 进程详细信息
    static func getProcessDetails(pid: String) -> String {
        do {
            return try Shell.runSync("ps -p \(pid) -o pid,ppid,user,time,command")
        } catch {
            return error.localizedDescription
        }
    }
    
    /// 监控进程资源使用情况
    /// - Parameter pid: 进程ID
    /// - Returns: 资源使用情况
    static func monitorProcess(pid: String) -> String {
        do {
            return try Shell.runSync("top -pid \(pid) -l 1")
        } catch {
            return error.localizedDescription
        }
    }
    
    /// 获取系统服务状态
    /// - Returns: 系统服务状态
    static func getSystemServices() -> String {
        do {
            return try Shell.runSync("launchctl list")
        } catch {
            return error.localizedDescription
        }
    }
    
    /// 启动系统服务
    /// - Parameter serviceName: 服务名称
    /// - Throws: 启动失败时抛出错误
    static func startService(_ serviceName: String) throws {
        try Shell.runSync("launchctl start \(serviceName)")
    }
    
    /// 停止系统服务
    /// - Parameter serviceName: 服务名称
    /// - Throws: 停止失败时抛出错误
    static func stopService(_ serviceName: String) throws {
        try Shell.runSync("launchctl stop \(serviceName)")
    }
}

#endif
