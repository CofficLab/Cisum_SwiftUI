import AVFoundation
import Foundation
import OSLog
import SwiftData
import SwiftUI

class AudioMeta {
    let fileManager = FileManager.default

    var audio: Audio
    var title = "[空白]"
    var artist = ""
    var track = ""
    var albumName = ""
    var order: Int = 0
    var coverURL: URL?
    var downloadingPercent: Double = 0
    var isDownloading: Bool = false
    var isPlaceholder: Bool = false

    init(_ audio: Audio) {
        // os_log("\(Logger.isMain)🚩 AudioModel::init -> \(url.lastPathComponent)")
        self.audio = audio
    }

    func updateMeta() async {
        let asset = AVAsset(url: audio.url)
        do {
            let metadata = try await asset.load(.commonMetadata)

            for item in metadata {
                do {
                    let value = try await item.load(.value)

                    switch item.commonKey?.rawValue {
                    case "title":
                        if let title = value as? String {
                            // os_log("\(Logger.isMain)🍋 AudioModel::updateMeta -> title: \(title)")
                            self.title = title
                        } else {
                            os_log("\(Logger.isMain)meta提供了title，但value不能转成string")
                        }
                    case "artist":
                        if let artist = value as? String {
                            self.artist = artist
                        }
                    case "albumName":
                        if let albumName = value as? String {
                            self.albumName = albumName
                        }
                    case "artwork":

                        // MARK: 得到了封面图

                        if try (makeImage(await item.load(.value), saveTo: audio.coverCacheURL)) != nil {
//                            coverURL = coverCacheURL
//                            os_log("\(Logger.isMain)🍋 AudioModel::updateMeta -> cover updated -> \(self.title)")
                        }
                    default:
                        break
                    }
                } catch {
                    os_log("\(Logger.isMain)读取 Meta 出错\n\(error)")
                }
            }
        } catch {}
    }

    /// 将封面图存到磁盘
    func makeImage(_ data: (any NSCopying & NSObjectProtocol)?, saveTo: URL) -> Image? {
        // os_log("\(Logger.isMain)AudioModel::makeImage -> \(saveTo.path)")
        guard let data = data as? Data else {
            return nil
        }

        do {
            try data.write(to: saveTo)
        } catch let e {
            print(e)
        }

        #if os(iOS)
            if let image = UIImage(data: data) {
                return Image(uiImage: image)
            }
        #endif

        #if os(macOS)
            if let image = NSImage(data: data) {
                return Image(nsImage: image)
            }
        #endif

        return nil
    }
}

#Preview("App") {
    RootView {
        ContentView()
    }
}
