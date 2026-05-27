import Foundation
import OSLog
import SwiftUI
#if os(macOS)
extension ShellGit {
    /// 合并分支
    /// - Parameters:
    ///   - branchName: 要合并的分支名称
    ///   - path: 仓库路径
    /// - Returns: 执行结果
    public static func merge(_ branchName: String, at path: String? = nil) throws -> String {
        return try Shell.runSync("git merge \(branchName)", at: path)
    }
    
    /// 快进合并
    /// - Parameters:
    ///   - branchName: 要合并的分支名称
    ///   - path: 仓库路径
    /// - Returns: 执行结果
    public static func mergeFastForward(_ branchName: String, at path: String? = nil) throws -> String {
        return try Shell.runSync("git merge --ff-only \(branchName)", at: path)
    }
    
    /// 非快进合并（创建合并提交）
    /// - Parameters:
    ///   - branchName: 要合并的分支名称
    ///   - message: 合并提交信息
    ///   - path: 仓库路径
    /// - Returns: 执行结果
    public static func mergeNoFastForward(_ branchName: String, message: String? = nil, at path: String? = nil) throws -> String {
        var command = "git merge --no-ff \(branchName)"
        if let message = message {
            command += " -m \"\(message)\""
        }
        return try Shell.runSync(command, at: path)
    }
    
    /// 压缩合并（将分支的所有提交压缩为一个提交）
    /// - Parameters:
    ///   - branchName: 要合并的分支名称
    ///   - path: 仓库路径
    /// - Returns: 执行结果
    public static func mergeSquash(_ branchName: String, at path: String? = nil) throws -> String {
        return try Shell.runSync("git merge --squash \(branchName)", at: path)
    }
    
    /// 使用指定策略合并
    /// - Parameters:
    ///   - branchName: 要合并的分支名称
    ///   - strategy: 合并策略（ours, theirs, recursive, resolve, octopus, subtree）
    ///   - path: 仓库路径
    /// - Returns: 执行结果
    public static func mergeWithStrategy(_ branchName: String, strategy: String, at path: String? = nil) throws -> String {
        return try Shell.runSync("git merge -s \(strategy) \(branchName)", at: path)
    }
    
    /// 中止合并
    /// - Parameter path: 仓库路径
    /// - Returns: 执行结果
    public static func mergeAbort(at path: String? = nil) throws -> String {
        return try Shell.runSync("git merge --abort", at: path)
    }
    
    /// 继续合并（解决冲突后）
    /// - Parameter path: 仓库路径
    /// - Returns: 执行结果
    public static func mergeContinue(at path: String? = nil) throws -> String {
        return try Shell.runSync("git merge --continue", at: path)
    }
    
    /// 检查是否正在进行合并
    /// - Parameter path: 仓库路径
    /// - Returns: 是否正在合并
    public static func isMerging(at path: String? = nil) throws -> Bool {
        do {
            _ = try Shell.runSync("git rev-parse --verify MERGE_HEAD", at: path)
            return true
        } catch {
            return false
        }
    }
    
    /// 获取合并冲突文件列表
    /// - Parameter path: 仓库路径
    /// - Returns: 冲突文件列表
    public static func mergeConflictFiles(at path: String? = nil) throws -> [String] {
        let output = try Shell.runSync("git diff --name-only --diff-filter=U", at: path)
        return output.split(separator: "\n").map { String($0) }.filter { !$0.isEmpty }
    }
    
    /// 获取合并状态信息
    /// - Parameter path: 仓库路径
    /// - Returns: 合并状态信息
    public static func mergeStatus(at path: String? = nil) throws -> String {
        if try isMerging(at: path) {
            let conflictFiles = try mergeConflictFiles(at: path)
            if conflictFiles.isEmpty {
                return "正在合并，无冲突文件"
            } else {
                return "正在合并，冲突文件：\(conflictFiles.joined(separator: ", "))"
            }
        } else {
            return "未在合并状态"
        }
    }
    
    /// 使用我们的版本解决冲突
    /// - Parameters:
    ///   - files: 文件列表，为空则应用于所有冲突文件
    ///   - path: 仓库路径
    /// - Returns: 执行结果
    public static func mergeResolveOurs(_ files: [String] = [], at path: String? = nil) throws -> String {
        if files.isEmpty {
            return try Shell.runSync("git checkout --ours .", at: path)
        } else {
            let filesStr = files.joined(separator: " ")
            return try Shell.runSync("git checkout --ours \(filesStr)", at: path)
        }
    }
    
    /// 使用他们的版本解决冲突
    /// - Parameters:
    ///   - files: 文件列表，为空则应用于所有冲突文件
    ///   - path: 仓库路径
    /// - Returns: 执行结果
    public static func mergeResolveTheirs(_ files: [String] = [], at path: String? = nil) throws -> String {
        if files.isEmpty {
            return try Shell.runSync("git checkout --theirs .", at: path)
        } else {
            let filesStr = files.joined(separator: " ")
            return try Shell.runSync("git checkout --theirs \(filesStr)", at: path)
        }
    }
}
#endif

// MARK: - Preview

#if DEBUG && os(macOS)
#Preview("ShellGit+Merge Demo") {
    ShellGitMergePreview()
        
} 
#endif
