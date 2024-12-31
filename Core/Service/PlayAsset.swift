import AVKit
import MagicKit
import MagicUI
import OSLog
import SwiftUI

/* PlayAsset 用于代表可播放、展示的个体

    可以从以下数据转换而来：
      一条数据库记录
      一个文件URL
 */

struct PlayAsset: FileBox, Identifiable, SuperEvent, SuperLog {
    static let emoji = "🎹"

    var id: URL { self.url }

    let fm = FileManager.default

    var url: URL
    var contentType: String?
    var like: Bool = false
    var size: Int64?
    var notLike: Bool { !like }
    var delegate: PlayAssetDelegate

    func isSupported() -> Bool {
        self.isFolder() || Config.supportedExtensions.contains(ext.lowercased())
    }
    
    func isAudio() -> Bool {
        !isVideo()
    }
    
    func getCoverImage() async throws -> Image? {
        return try await self.getCoverImage(verbose: false)
    }
    
    func getPlatformImage() async throws -> PlatformImage? {
        nil
    }

    func delete() async throws {
        try await self.delegate.delete()
    }

    func download() async throws {
        try await url.download()
    }
    
    mutating func toggleLike() async throws {
        self.like.toggle()
        try await self.delegate.onLikeChange(like: self.like, asset: self)
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
        self.url.getSizeReadable()
    }
}

extension PlayAsset: SuperCover {
    var coverFolder: URL { AudioConfig.getCoverFolderUrl() }
    var defaultImage: Image {
        #if os(macOS)
            Image(nsImage: NSImage(named: "DefaultAlbum")!)
        #else
            Image(uiImage: UIImage(imageLiteralResourceName: "DefaultAlbum"))
        #endif
    }
}

// MARK: Transform

//extension PlayAsset {
//    static func fromURL(_ url: URL) -> PlayAsset {
//        PlayAsset(url: url)
//    }
//}

enum PlayAssetError: Error, LocalizedError {
    case sourceNotFound
    case notImplemented

    var errorDescription: String? {
        switch self {
        case .sourceNotFound:
            return "PlayAsset: Source not found"
        case .notImplemented:
            return "PlayAsset: Not implemented"
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
