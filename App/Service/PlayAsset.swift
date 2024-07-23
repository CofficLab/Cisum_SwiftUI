import AVKit
import OSLog
import SwiftUI

/* PlayAsset 用于代表可播放、展示的个体
 
    可以从以下数据转换而来：
      一条数据库记录
      一个文件URL
 */

struct PlayAsset: FileBox, Identifiable, Equatable {
    var id: URL { self.url }
    
    static var label = "🪖 PlayAsset::"

    let fileManager = FileManager.default

    var url: URL
    var contentType: String?
    var like: Bool = false
    var size: Int64?

    var notLike: Bool { !like }
    var label: String { "\(Logger.isMain)\(Self.label)" }

    func isSupported() -> Bool {
        self.isFolder() || Config.supportedExtensions.contains(ext.lowercased())
    }

    // MARK: 控制中心的图

    func getMediaCenterImage<T>() -> T {
        #if os(macOS)
            var i = defaultNSImage
        #else
            var i = defaultUIImage
        #endif
        
        if fileManager.fileExists(atPath: coverCacheURL.path) {
            #if os(macOS)
                i = NSImage(contentsOf: coverCacheURL) ?? i
            #else
                i = UIImage(contentsOfFile: coverCacheURL.path) ?? i
            #endif
        }

        return i as! T
    }
}

// MARK: Format

extension PlayAsset {
    func isAudio() -> Bool {
        !isVideo()
    }
}

// MARK: Size

extension PlayAsset {
    func getFileSizeReadable() -> String {
        FileHelper.getFileSizeReadable(size ?? getFileSize())
    }
}

// MARK: Transform

extension PlayAsset {
    static func fromURL(_ url: URL) -> PlayAsset {
        PlayAsset(url: url)
    }
}

#Preview {
    AppPreview()
        .frame(height: 800)
}
