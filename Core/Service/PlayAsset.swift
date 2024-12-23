import AVKit
import MagicKit
import OSLog
import SwiftUI

/* PlayAsset 用于代表可播放、展示的个体

    可以从以下数据转换而来：
      一条数据库记录
      一个文件URL
 */

struct PlayAsset: FileBox, Identifiable, SuperEvent, SuperLog {
    static let emoji = "🫓"

    var id: URL { self.url }

    let fm = FileManager.default

    var url: URL
    var contentType: String?
    var like: Bool = false
    var size: Int64?
    var notLike: Bool { !like }
    var source: PlaySource?

    func isSupported() -> Bool {
        self.isFolder() || Config.supportedExtensions.contains(ext.lowercased())
    }
    
    func isAudio() -> Bool {
        !isVideo()
    }

    // MARK: 控制中心的图

    func getMediaCenterImage<T>() -> T {
        #if os(macOS)
            var i = defaultNSImage
        #else
            var i = defaultUIImage
        #endif

        if fm.fileExists(atPath: coverCacheURL.path) {
            #if os(macOS)
                i = NSImage(contentsOf: coverCacheURL) ?? i
            #else
                i = UIImage(contentsOfFile: coverCacheURL.path) ?? i
            #endif
        }

        return i as! T
    }

    func delete() async throws {
        guard let source = source else {
            throw PlayAssetError.sourceNotFound
        }

        try await source.delete()

        emit(name: .playAssetDeleted, object: self)
    }

    func download() async throws {
        guard let source = source else {
            throw PlayAssetError.sourceNotFound
        }

        try await source.download()
    }

    func setSource(_ source: PlaySource) -> PlayAsset {
        var updated = self
        updated.source = source
        return updated
    }
    
    func toggleLike() throws {
        guard let source = source else {
            throw PlayAssetError.sourceNotFound
        }

        Task {
            try await source.toggleLike()
        }
    }
}

extension PlayAsset: Equatable {
    static func == (lhs: PlayAsset, rhs: PlayAsset) -> Bool {
        lhs.url == rhs.url
    }
}

// MARK: Size

extension PlayAsset {
    func getFileSizeReadable(verbose: Bool = false) -> String {
        if verbose {
            os_log("\(self.t) GetFileSizeReadable: \(FileHelper.getFileSizeReadable(size ?? getFileSize()))")
        }

        return FileHelper.getFileSizeReadable(size ?? getFileSize())
    }
}

// MARK: Transform

extension PlayAsset {
    static func fromURL(_ url: URL) -> PlayAsset {
        PlayAsset(url: url)
    }
}

enum PlayAssetError: Error, LocalizedError {
    case sourceNotFound

    var errorDescription: String? {
        switch self {
        case .sourceNotFound:
            return "PlayAsset: Source not found"
        }
    }
}

extension Notification.Name {
    static let playAssetDeleted = Notification.Name("PlayAssetDeleted")
}

#Preview {
    AppPreview()
        .frame(height: 800)
}
