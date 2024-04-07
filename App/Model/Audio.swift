import AVFoundation
import Foundation
import OSLog
import SwiftData
import SwiftUI

@Model
class Audio {
    @Transient let fileManager = FileManager.default
    @Transient var onUpdated: (Audio) -> Void = { _ in os_log("Audio.onUpdated") }

    var url: URL
    var title = "[空白]"
    var artist = ""
    var track = ""
    var albumName = ""
    var order: Int = Int.random(in: 0...500000000)
    var coverURL: URL?
    var downloadingPercent: Double = 0
    var isDownloading: Bool = false
    var isPlaceholder: Bool = false
    
    var size: Int64 { getFileSize() }
    var ext: String { url.pathExtension }
    var isSupported: Bool { AppConfig.supportedExtensions.contains(ext) }
    var isNotSupported: Bool { !isSupported }

    init(_ url: URL) {
        // os_log("\(Logger.isMain)🚩 AudioModel::init -> \(url.lastPathComponent)")
        self.url = url
        title = url.deletingPathExtension().lastPathComponent
        coverURL = getCover()
        
        Task {
            await updateMeta()
        }
    }
    
    func makeRandomOrder() {
        self.order = Int.random(in: 0...500000000)
    }

    func getFileSize() -> Int64 {
        FileHelper.getFileSize(url)
    }

    func getFileSizeReadable() -> String {
        FileHelper.getFileSizeReadable(url)
    }
}

// MARK: ID

extension Audio: Identifiable {
    var id: URL { url }
}

// MARK: iCloud 相关

extension Audio {
    var isDownloaded: Bool { downloadingPercent == 100 }
    var isNotDownloaded: Bool { !isDownloaded }
}

// MARK: Meta

extension Audio {
    var coverCacheURL: URL {
        let fileName = url.lastPathComponent
        let imageName = fileName
        let coversDir = AppConfig.coverDir

        do {
            try fileManager.createDirectory(
                at: coversDir, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print(error.localizedDescription)
        }

        return coversDir
            .appendingPathComponent(imageName)
            .appendingPathExtension("jpeg")
    }
}

// MARK: Meta

extension Audio {
    func updateMeta() async {
        let asset = AVAsset(url: url)
        do {
            let metadata = try await asset.load(.commonMetadata)

            for item in metadata {
                do {
                    let value = try await item.load(.value)

                    switch item.commonKey?.rawValue {
                    case "title":
                        if let title = value as? String {
                             os_log("\(Logger.isMain)🍋 AudioModel::updateMeta -> title: \(title)")
                        } else {
                            os_log("\(Logger.isMain)meta提供了title，但value不能转成string")
                        }
                    case "artist":
                        if let artist = value as? String {
                            os_log("\(Logger.isMain)🍋 AudioModel::updateMeta -> artist: \(artist)")
                        }
                    case "albumName":
                        if let albumName = value as? String {
                            os_log("\(Logger.isMain)🍋 AudioModel::updateMeta -> albumName: \(albumName)")
                        }
                    case "artwork":

                        // MARK: 得到了封面图

                        if try (makeImage(await item.load(.value), saveTo: coverCacheURL)) != nil {
                            self.coverURL = coverCacheURL
                            os_log("\(Logger.isMain)🍋 AudioModel::updateMeta -> cover updated -> \(self.title)")
                        }
                    default:
                        break
                    }
                    
                    self.onUpdated(self)
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

// MARK: Cover

extension Audio {
    #if os(iOS)
        var uiImage: UIImage {
            var i = UIImage(imageLiteralResourceName: "DefaultAlbum")
            if isCoverOnDisk() {
                i = UIImage(contentsOfFile: coverCacheURL.path) ?? i
            }

            return i
        }
    #endif

    func getCover() -> URL? {
        if isNotDownloaded {
            return nil
        }

        if fileManager.fileExists(atPath: coverCacheURL.path) {
            return coverCacheURL
        }

        return nil
    }
}

#Preview("App") {
    RootView {
        ContentView()
    }
}
