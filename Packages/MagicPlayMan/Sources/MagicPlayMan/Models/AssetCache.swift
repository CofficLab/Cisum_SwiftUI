import Foundation
import AVFoundation
import SwiftUI
import CisumUI
import CryptoKit

public class AssetCache {
    private let cacheDirectory: URL
    private let fileManager = FileManager.default
    
    /// 创建资源缓存管理器
    /// - Parameter directory: 自定义缓存目录。如果为 nil，则使用系统默认缓存目录下的 MagicPlayMan 文件夹
    init(directory: URL? = nil) throws {
        if let customDirectory = directory {
            cacheDirectory = customDirectory
        } else {
            let cacheDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first
                ?? fileManager.temporaryDirectory
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
        fileManager.fileExists(atPath: cacheFileURL(for: url).path)
    }
    
    /// 获取缓存文件的 URL
    func cachedURL(for url: URL) -> URL? {
        let cachedURL = cacheFileURL(for: url)
        return fileManager.fileExists(atPath: cachedURL.path) ? cachedURL : nil
    }
    
    /// 缓存数据
    func cache(_ data: Data, for url: URL) throws {
        try data.write(to: cacheFileURL(for: url))
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
    func validateCache(for url: URL) async -> Bool {
        guard let cachedURL = cachedURL(for: url),
              FileManager.default.fileExists(atPath: cachedURL.path) else {
            return false
        }

        let asset = AVURLAsset(url: cachedURL)

        do {
            let isPlayable = try await asset.load(.isPlayable)
            _ = try await asset.load(.duration)
            return isPlayable
        } catch {
            return false
        }
    }
    
    /// 删除指定 URL 的缓存
    func removeCached(_ url: URL) {
        guard let cachedURL = cachedURL(for: url) else { return }
        try? FileManager.default.removeItem(at: cachedURL)
    }

    private func cacheFileURL(for url: URL) -> URL {
        let digest = SHA256.hash(data: Data(url.absoluteString.utf8))
        let encodedURL = digest.map { String(format: "%02x", $0) }.joined()
        let pathExtension = url.pathExtension
        let filename = pathExtension.isEmpty ? encodedURL : "\(encodedURL).\(pathExtension)"

        return cacheDirectory.appendingPathComponent(filename)
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
