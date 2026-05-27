import Foundation
import OSLog
import SwiftUI
#if os(macOS)
extension ShellGit {
    /// 克隆远程仓库
    /// - Parameters:
    ///   - url: 远程仓库URL
    ///   - destination: 本地目标路径，如果为空则使用仓库名
    ///   - branch: 指定分支名，如果为空则克隆默认分支
    ///   - depth: 克隆深度，如果为空则完整克隆
    /// - Returns: 执行结果
    public static func clone(_ url: String, to destination: String? = nil, branch: String? = nil, depth: Int? = nil) throws -> String {
        var command = "git clone"
        
        // 添加分支参数
        if let branch = branch {
            command += " -b \(branch)"
        }
        
        // 添加深度参数
        if let depth = depth {
            command += " --depth \(depth)"
        }
        
        // 添加URL
        command += " \(url)"
        
        // 添加目标路径
        if let destination = destination {
            command += " \(destination)"
        }
        
        return try Shell.runSync(command)
    }
    
    /// 浅克隆远程仓库（只克隆最新的提交）
    /// - Parameters:
    ///   - url: 远程仓库URL
    ///   - destination: 本地目标路径
    ///   - depth: 克隆深度，默认为1
    /// - Returns: 执行结果
    public static func shallowClone(_ url: String, to destination: String? = nil, depth: Int = 1) throws -> String {
        return try clone(url, to: destination, depth: depth)
    }
    
    /// 克隆指定分支
    /// - Parameters:
    ///   - url: 远程仓库URL
    ///   - branch: 分支名
    ///   - destination: 本地目标路径
    /// - Returns: 执行结果
    public static func cloneBranch(_ url: String, branch: String, to destination: String? = nil) throws -> String {
        return try clone(url, to: destination, branch: branch)
    }
    
    /// 克隆并进入指定目录
    /// - Parameters:
    ///   - url: 远程仓库URL
    ///   - destination: 本地目标路径
    /// - Returns: (执行结果, 仓库本地路径)
    public static func cloneAndGetPath(_ url: String, to destination: String? = nil) throws -> (result: String, repoPath: String) {
        let result = try clone(url, to: destination)
        
        // 确定实际的仓库路径
        let repoPath: String
        if let destination = destination {
            repoPath = destination
        } else {
            // 从URL提取仓库名
            let repoName = url.split(separator: "/").last?.replacingOccurrences(of: ".git", with: "") ?? "repository"
            repoPath = repoName
        }
        
        return (result, repoPath)
    }
    
    /// 递归克隆（包含子模块）
    /// - Parameters:
    ///   - url: 远程仓库URL
    ///   - destination: 本地目标路径
    ///   - branch: 指定分支名
    /// - Returns: 执行结果
    public static func cloneRecursive(_ url: String, to destination: String? = nil, branch: String? = nil) throws -> String {
        var command = "git clone --recurse-submodules"
        
        if let branch = branch {
            command += " -b \(branch)"
        }
        
        command += " \(url)"
        
        if let destination = destination {
            command += " \(destination)"
        }
        
        return try Shell.runSync(command)
    }
    
    /// 裸克隆（用于服务器端）
    /// - Parameters:
    ///   - url: 远程仓库URL
    ///   - destination: 本地目标路径
    /// - Returns: 执行结果
    public static func cloneBare(_ url: String, to destination: String) throws -> String {
        return try Shell.runSync("git clone --bare \(url) \(destination)")
    }
    
    /// 镜像克隆（完整镜像）
    /// - Parameters:
    ///   - url: 远程仓库URL
    ///   - destination: 本地目标路径
    /// - Returns: 执行结果
    public static func cloneMirror(_ url: String, to destination: String) throws -> String {
        return try Shell.runSync("git clone --mirror \(url) \(destination)")
    }
    
    /// 检查URL是否为有效的Git仓库
    /// - Parameter url: 仓库URL
    /// - Returns: 是否为有效的Git仓库
    public static func isValidGitRepository(_ url: String) -> Bool {
        do {
            _ = try Shell.runSync("git ls-remote \(url)")
            return true
        } catch {
            return false
        }
    }
}
#endif
// MARK: - Preview

#if DEBUG && os(macOS)
#Preview("ShellGit+Clone Demo") {
    ShellGitClonePreview()
        
} 
#endif
