import Foundation
import CisumUI
import OSLog
import SwiftUI

/// 专门负责书籍封面图获取的仓库类
public final class BookCoverRepo: ObservableObject, SuperLog, @unchecked Sendable {
    public nonisolated static let emoji = "🖼️"
    private let verbose = false
    private nonisolated static let supportedCoverExtensions: Set<String> = [
        "apng",
        "bmp",
        "gif",
        "heic",
        "heif",
        "jpeg",
        "jpg",
        "png",
        "tif",
        "tiff",
        "webp",
    ]
    private nonisolated static let preferredCoverNames = [
        "cover",
        "folder",
        "front",
        "poster",
        "thumbnail",
    ]

    // MARK: - In-flight Deduplication & Cache

    /// Cache key: standardized URL path + thumbnail size
    private static func cacheKey(for url: URL, size: CGSize) -> String {
        "\(url.resolvingSymlinksInPath().standardizedFileURL.path)_\(Int(size.width))x\(Int(size.height))"
    }

    /// In-flight tasks to prevent concurrent loads of the same cover.
    /// Key: cache key, Value: ongoing Task that produces the cover image.
    nonisolated(unsafe) private static var inFlightTasks: [String: Task<Image?, Never>] = [:]

    /// Result cache to avoid re-scanning the file system for already-loaded covers.
    nonisolated(unsafe) private static var resultCache: [String: Image?] = [:]

    // MARK: - Public Methods

    /// 获取书籍封面图
    /// - Parameters:
    ///   - url: 书籍URL
    ///   - thumbnailSize: 缩略图尺寸
    /// - Returns: 封面图，如果未找到则返回nil
    func getCover(for url: URL, thumbnailSize: CGSize) async -> Image? {
        let key = Self.cacheKey(for: url, size: thumbnailSize)

        // 1. Check result cache first
        if let cached = Self.resultCache[key] {
            return cached
        }

        // 2. Check in-flight tasks for deduplication
        if let existingTask = Self.inFlightTasks[key] {
            return await existingTask.value
        }

        // 3. Start a new task
        let task = Task<Image?, Never> {
            do {
                let result = try await Self.findCoverRecursively(in: url, thumbnailSize: thumbnailSize, verbose: verbose)
                Self.resultCache[key] = result
                return result
            } catch {
                os_log(.error, "\(Self.t)Failed to find cover for \(url.lastPathComponent): \(error.localizedDescription)")
                Self.resultCache[key] = nil
                return nil
            }
        }

        Self.inFlightTasks[key] = task
        let result = await task.value
        Self.inFlightTasks.removeValue(forKey: key)
        return result
    }

    /// Clears the cover cache. Call when books are refreshed or deleted.
    public static func clearCache() {
        resultCache.removeAll()
        // Cancel any in-flight tasks
        for (_, task) in inFlightTasks {
            task.cancel()
        }
        inFlightTasks.removeAll()
    }

    /// Clears cache for a specific book URL.
    static func clearCache(for url: URL) {
        let prefix = url.resolvingSymlinksInPath().standardizedFileURL.path
        resultCache = resultCache.filter { !$0.key.hasPrefix(prefix) }
    }

    // MARK: - Private Methods

    /// 递归查找封面图
    /// - Parameters:
    ///   - url: 目录URL
    ///   - thumbnailSize: 缩略图尺寸
    ///   - verbose: 是否输出详细日志
    /// - Returns: 封面图，如果未找到则返回nil
    private static func findCoverRecursively(in url: URL, thumbnailSize: CGSize, verbose: Bool) async throws -> Image? {
        // 确保在后台线程执行文件系统操作
        return try await withCheckedThrowingContinuation { continuation in
            Task.detached(priority: .background) {
                do {
                    if verbose {
                        os_log("\(Self.t)findCoverRecursively \(url.title)")
                    }
                    let candidates = coverCandidates(in: url)

                    // 首先检查当前层级的文件
                    for child in candidates.files {
                        // 跳过未下载的 iCloud 文件
                        if child.checkIsICloud(verbose: false) && child.isNotDownloaded {
                            continue
                        }

                        if let cover = try await child.thumbnailImage(
                            size: thumbnailSize,
                            useDefaultIcon: false,
                            verbose: verbose,
                            reason: "BookCoverRepo"
                        ) {
                            continuation.resume(returning: cover)
                            return
                        }
                    }

                    // 如果当前层级没有找到封面，递归查找子文件夹
                    for child in candidates.folders {
                        if let cover = try await findCoverRecursively(in: child, thumbnailSize: thumbnailSize, verbose: verbose) {
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

    static func coverCandidates(in url: URL) -> (files: [URL], folders: [URL]) {
        guard url.isFolder else {
            return ([url], [])
        }

        let children = url.getChildren().sorted {
            $0.standardizedFileURL.path.localizedStandardCompare($1.standardizedFileURL.path) == .orderedAscending
        }
        return (
            files: children.filter { !$0.isFolder && isCoverImageCandidate($0) }
                .sorted(by: coverFileSort),
            folders: children.filter(\.isFolder)
        )
    }

    static func isCoverImageCandidate(_ url: URL) -> Bool {
        supportedCoverExtensions.contains(url.pathExtension.lowercased())
    }

    private static func coverFileSort(_ lhs: URL, _ rhs: URL) -> Bool {
        let lhsRank = coverNameRank(lhs)
        let rhsRank = coverNameRank(rhs)
        if lhsRank != rhsRank {
            return lhsRank < rhsRank
        }

        return lhs.standardizedFileURL.path.localizedStandardCompare(rhs.standardizedFileURL.path) == .orderedAscending
    }

    private static func coverNameRank(_ url: URL) -> Int {
        let name = url.deletingPathExtension().lastPathComponent.lowercased()
        return preferredCoverNames.firstIndex(of: name) ?? preferredCoverNames.count
    }
}
