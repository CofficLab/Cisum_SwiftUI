import Foundation
import MagicCore
import OSLog
import SwiftUI

/// 专门负责书籍封面图获取的仓库类
class BookCoverRepo: ObservableObject, SuperLog {
    nonisolated static let emoji = "🖼️"
    
    // MARK: - Public Methods
    
    /// 获取书籍封面图
    /// - Parameters:
    ///   - url: 书籍URL
    ///   - thumbnailSize: 缩略图尺寸
    /// - Returns: 封面图，如果未找到则返回nil
    func getCover(for url: URL, thumbnailSize: CGSize) async -> Image? {
        do {
            return try await Self.findCoverRecursively(in: url, thumbnailSize: thumbnailSize)
        } catch {
            os_log(.error, "\(self.t)Failed to find cover for \(url.lastPathComponent): \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Private Methods
    
    /// 递归查找封面图
    /// - Parameters:
    ///   - url: 目录URL
    ///   - thumbnailSize: 缩略图尺寸
    /// - Returns: 封面图，如果未找到则返回nil
    private static func findCoverRecursively(in url: URL, thumbnailSize: CGSize) async throws -> Image? {
        // 确保在后台线程执行文件系统操作
        return try await withCheckedThrowingContinuation { continuation in
            Task.detached(priority: .background) {
                do {
                    os_log("\(Self.t)findCoverRecursively \(url.title)")
                    // 获取当前目录下的所有文件
                    let children = url.getChildren()

                    // 首先检查当前层级的文件
                    for child in children where !child.hasDirectoryPath {
                        // 跳过未下载的 iCloud 文件
                        if child.isiCloud && child.isNotDownloaded {
                            continue
                        }

                        // 使用 MagicKit 的 thumbnail 方法（内置缓存）
                        if let cover = try await child.thumbnail(
                            size: thumbnailSize, 
                            useDefaultIcon: false, 
                            verbose: true, 
                            reason: "BookCoverRepo"
                        ) {
                            continuation.resume(returning: cover)
                            return
                        }
                    }

                    // 如果当前层级没有找到封面，递归查找子文件夹
                    for child in children where child.hasDirectoryPath {
                        if let cover = try await findCoverRecursively(in: child, thumbnailSize: thumbnailSize) {
                            continuation.resume(returning: cover)
                            return
                        }
                    }

                    continuation.resume(returning: nil)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

// MARK: - Preview

#if os(macOS)
#Preview("App - Large") {
    AppPreview()
        .frame(width: 600, height: 1000)
}

#Preview("App - Small") {
    AppPreview()
        .frame(width: 600, height: 600)
}
#endif

#if os(iOS)
#Preview("iPhone") {
    AppPreview()
}
#endif
