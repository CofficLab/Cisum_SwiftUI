import Foundation
import OSLog
import SwiftUI
#if os(macOS)
extension ShellGit {
    /// 推送到远程仓库
    /// - Parameters:
    ///   - remote: 远程仓库名称，默认为origin
    ///   - branch: 分支名称，默认为当前分支
    ///   - path: 仓库路径
    /// - Returns: 执行结果
    @discardableResult
    public static func push(remote: String = "origin", branch: String? = nil, at path: String? = nil) throws -> String {
        let command = branch != nil ? "git push \(remote) \(branch!)" : "git push \(remote)"
        return try Shell.runSync(command, at: path)
    }
    
    /// 从远程仓库拉取
    /// - Parameters:
    ///   - remote: 远程仓库名称，默认为origin
    ///   - branch: 分支名称，默认为当前分支
    ///   - path: 仓库路径
    /// - Returns: 执行结果
    @discardableResult
    public static func pull(remote: String = "origin", branch: String? = nil, at path: String? = nil) throws -> String {
        let command = branch != nil ? "git pull \(remote) \(branch!)" : "git pull \(remote)"
        return try Shell.runSync(command, at: path)
    }
    
    /// 添加远程仓库
    /// - Parameters:
    ///   - name: 远程仓库名称
    ///   - url: 远程仓库URL
    ///   - path: 仓库路径
    /// - Returns: 执行结果
    public static func addRemote(_ name: String, url: String, at path: String? = nil) throws -> String {
        return try Shell.runSync("git remote add \(name) \(url)", at: path)
    }
    
    /// 获取远程仓库列表
    /// - Parameters:
    ///   - verbose: 是否显示详细信息
    ///   - path: 仓库路径
    /// - Returns: 远程仓库列表，字符串形式
    public static func remotes(verbose: Bool = false, at path: String? = nil) throws -> String {
        let option = verbose ? "-v" : ""
        return try Shell.runSync("git remote \(option)", at: path)
    }

    /// 获取远程仓库列表-数组
    /// - Parameters:
    ///   - verbose: 是否显示详细信息
    ///   - path: 仓库路径
    /// - Returns: 远程仓库列表，字符串数组形式
    public static func remotesArray(verbose: Bool = false, at path: String? = nil) throws -> [String] {
        let output = try remotes(verbose: verbose, at: path)
        return output.split(separator: "\n").map { String($0) }
    }

    /// 获取第一个远程仓库的URL
    /// - Parameter path: 仓库路径
    /// - Returns: 第一个远程仓库的URL，如果不存在则返回nil
    public static func firstRemoteURL(at path: String? = nil) throws -> String? {
        let output = try Shell.runSync("git remote -v", at: path)
        let lines = output.split(separator: "\n").map { String($0) }
        guard let firstLine = lines.first else { return nil }
        // 示例输出: origin	https://github.com/user/repo.git (fetch)
        let components = firstLine.split(separator: "\t").map { String($0) }
        guard components.count > 1 else { return nil }
        let urlPart = components[1]
        let url = urlPart.split(separator: " ").first.map { String($0) }
        return url
    }
    
    /// 删除远程仓库
    /// - Parameters:
    ///   - name: 远程仓库名称
    ///   - path: 仓库路径
    /// - Returns: 执行结果
    public static func removeRemote(_ name: String, at path: String? = nil) throws -> String {
        return try Shell.runSync("git remote remove \(name)", at: path)
    }

    /// 修改远程仓库URL
    /// - Parameters:
    ///   - name: 远程仓库名称
    ///   - url: 新的远程仓库URL
    ///   - path: 仓库路径
    /// - Returns: 执行结果
    public static func setRemoteURL(_ name: String, url: String, at path: String? = nil) throws -> String {
        return try Shell.runSync("git remote set-url \(name) \(url)", at: path)
    }

    /// 获取远程结构体列表
    /// - Parameters:
    ///   - path: 仓库路径
    /// - Returns: 远程结构体数组
    public static func remoteList(at path: String? = nil) throws -> [MagicGitRemote] {
        let output = try remotes(verbose: true, at: path)
        let lines = output.split(separator: "\n").map { String($0) }
        var remotes: [MagicGitRemote] = []
        var seen: Set<String> = []
        for line in lines {
            // 例如 origin\thttps://github.com/user/repo.git (fetch)
            let parts = line.split(separator: "\t").map { String($0) }
            guard parts.count == 2 else { continue }
            let name = parts[0]
            let urlAndType = parts[1].split(separator: " ").map { String($0) }
            guard urlAndType.count >= 2 else { continue }
            let url = urlAndType[0]
            let type = urlAndType[1]
            var fetchURL: String? = nil
            var pushURL: String? = nil
            if type == "(fetch)" { fetchURL = url }
            if type == "(push)" { pushURL = url }
            if let idx = remotes.firstIndex(where: { $0.name == name }) {
                // 已有，补充 push/fetch
                if fetchURL != nil { remotes[idx] = MagicGitRemote(id: name, name: name, url: remotes[idx].url, fetchURL: fetchURL, pushURL: remotes[idx].pushURL, isDefault: idx == 0) }
                if pushURL != nil { remotes[idx] = MagicGitRemote(id: name, name: name, url: remotes[idx].url, fetchURL: remotes[idx].fetchURL, pushURL: pushURL, isDefault: idx == 0) }
            } else {
                remotes.append(MagicGitRemote(id: name, name: name, url: url, fetchURL: fetchURL, pushURL: pushURL, isDefault: remotes.isEmpty))
            }
        }
        return remotes
    }
}
#endif
// MARK: - Preview

#if DEBUG && os(macOS)
#Preview("ShellGit+Remote Demo") {
    ShellGitRemotePreview()
        
} 
#endif
