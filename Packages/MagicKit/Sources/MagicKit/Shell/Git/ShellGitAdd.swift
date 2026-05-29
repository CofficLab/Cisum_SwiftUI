import Foundation
import OSLog
import SwiftUI
#if os(macOS)
extension ShellGit {
    /// 将文件添加到暂存区
    /// - Parameters:
    ///   - files: 要添加的文件路径数组，为空则添加所有文件
    ///   - path: 仓库路径
    public static func add(_ files: [String] = [], at path: String? = nil) throws {
        let filesStr = files.isEmpty ? "." : files.joined(separator: " ")
        try Shell.runSync("git add \(filesStr)", at: path)
    }
    
    /// 将文件从暂存区移除
    /// - Parameters:
    ///   - files: 要移除的文件路径数组，为空则移除所有文件
    ///   - path: 仓库路径
    public static func reset(_ files: [String] = [], at path: String? = nil) throws {
        let filesStr = files.isEmpty ? "." : files.joined(separator: " ")
        try Shell.runSync("git reset \(filesStr)", at: path)
    }
}
#endif

#if DEBUG && os(macOS)
#Preview("ShellGit+Add Demo") {
    ShellGitAddPreview()
} 
#endif
