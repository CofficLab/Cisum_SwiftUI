import Foundation
import AVFoundation
import SwiftUI

public class AssetCache {
    private let cacheDirectory: URL
    private let fileManager = FileManager.default
    
    /// 创建资源缓存管理器
    /// - Parameter directory: 自定义缓存目录。如果为 nil，则使用系统默认缓存目录下的 MagicPlayMan 文件夹
    init(directory: URL? = nil) throws {
        if let customDirectory = directory {
            cacheDirectory = customDirectory
        } else {
            let cacheDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
            cacheDirectory = cacheDir.appendingPathComponent("MagicPlayMan", isDirectory: true)
        }
        
        // 确保缓存目录存在
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
    }
    
    /// 获取缓存目录路径
    var directory: URL {
        cacheDirectory
    }
    
    /// 检查资源是否已缓存
    func isCached(_ url: URL) -> Bool {
        let filename = url.lastPathComponent
        let cachedURL = cacheDirectory.appendingPathComponent(filename)
        return fileManager.fileExists(atPath: cachedURL.path)
    }
    
    /// 获取缓存文件的 URL
    func cachedURL(for url: URL) -> URL? {
        let filename = url.lastPathComponent
        let cachedURL = cacheDirectory.appendingPathComponent(filename)
        return fileManager.fileExists(atPath: cachedURL.path) ? cachedURL : nil
    }
    
    /// 缓存数据
    func cache(_ data: Data, for url: URL) throws {
        let filename = url.lastPathComponent
        let cachedURL = cacheDirectory.appendingPathComponent(filename)
        try data.write(to: cachedURL)
    }
    
    /// 清理所有缓存
    func clear() throws {
        let contents = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
        for url in contents {
            try fileManager.removeItem(at: url)
        }
    }
    
    /// 获取缓存大小（字节）
    func size() throws -> UInt64 {
        let contents = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey])
        return try contents.reduce(0) { total, url in
            let attributes = try fileManager.attributesOfItem(atPath: url.path)
            return total + (attributes[.size] as? UInt64 ?? 0)
        }
    }
    
    /// 验证缓存文件是否有效
    func validateCache(for url: URL) -> Bool {
        guard let cachedURL = cachedURL(for: url),
              FileManager.default.fileExists(atPath: cachedURL.path) else {
            return false
        }
        
        // 尝试创建 AVAsset 来验证文件
        let asset = AVAsset(url: cachedURL)
        let validationKeys = ["playable", "duration"]
        
        return asset.statusOfValue(forKey: "playable", error: nil) == .loaded &&
               asset.statusOfValue(forKey: "duration", error: nil) == .loaded
    }
    
    /// 删除指定 URL 的缓存
    func removeCached(_ url: URL) {
        guard let cachedURL = cachedURL(for: url) else { return }
        try? FileManager.default.removeItem(at: cachedURL)
    }
} 

#Preview("With Logs") {
    MagicPlayMan.getPreviewView()
        .frame(width: 650, height: 650)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 5)
        .padding()
}
