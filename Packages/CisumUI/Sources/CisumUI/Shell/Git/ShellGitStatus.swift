import Foundation
import OSLog
import SwiftUI

#if os(macOS)
extension ShellGit {
    /// 获取暂存区的状态
    /// - Parameter path: 仓库路径
    /// - Returns: 暂存区状态信息
    public static func status(at path: String? = nil) throws -> String {
        return try Shell.runSync("git status", at: path)
    }

    /// 获取简洁的状态信息
    /// - Parameter path: 仓库路径
    /// - Returns: 简洁的状态信息
    public static func statusPorcelain(at path: String? = nil) throws -> String {
        return try Shell.runSync("git status --porcelain", at: path)
    }

    /// 获取暂存区文件列表
    /// - Parameter path: 仓库路径
    /// - Returns: 暂存区文件列表
    public static func stagedFiles(at path: String? = nil) throws -> [String] {
        let output = try Shell.runSync("git diff --cached --name-only", at: path)
        return output.split(separator: "\n").map { String($0) }
    }

    /// 获取未暂存的文件列表
    /// - Parameter path: 仓库路径
    /// - Returns: 未暂存的文件列表
    public static func unstagedFiles(at path: String? = nil) throws -> [String] {
        let output = try Shell.runSync("git status --porcelain -z --untracked-files=all", at: path)
        return output.split(separator: "\0").compactMap { line in
            parseUnstagedFile(fromPorcelainLine: String(line))
        }
    }

    /// 判断本地是否有未提交的变动
    /// - Parameter path: 仓库路径
    /// - Returns: 如果有未提交的变动则返回true，否则返回false
    public static func hasUncommittedChanges(at path: String? = nil) throws -> Bool {
        let output = try statusPorcelain(at: path)
        return !output.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    static func parseUnstagedFile(fromPorcelainLine line: String) -> String? {
        guard line.count >= 4 else { return nil }
        let status = String(line.prefix(2))
        let path = String(line.dropFirst(3))
        guard !path.isEmpty else { return nil }

        if status == "??" {
            return path
        }

        guard let worktreeStatus = status.last, worktreeStatus != " " else {
            return nil
        }

        return pathAfterRenameMarker(path)
    }

    private static func pathAfterRenameMarker(_ path: String) -> String {
        path.components(separatedBy: " -> ").last ?? path
    }
}
#endif

// MARK: - Preview

#if DEBUG && os(macOS)
#Preview("ShellGit+Status Demo") {
    ShellGitStatusPreview()

}
#endif
