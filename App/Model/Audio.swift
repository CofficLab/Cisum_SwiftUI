import AVFoundation
import Foundation
import OSLog
import SwiftUI

class Audio {
    let fileManager = FileManager.default
    private let url: URL
    private var cacheURL: URL?
    var title = "[空白]"
    var artist = ""
    var description = ""
    var track = ""
    var albumName = ""
    var delegate: SuperAudioDelegate
    var cover: URL?
    var downloadingPercent: Double = 0
    var isDownloading: Bool = false
    var size: Int64 {
        getFileSize()
    }

    init(_ url: URL, cacheURL: URL? = nil, delegate: SuperAudioDelegate = SuperAudioDelegateSample()) {
        // os_log("\(Logger.isMain)🚩 AudioModel::init -> \(url.lastPathComponent)")
        self.url = url
        self.cacheURL = cacheURL
        self.delegate = delegate
        title = url.deletingPathExtension().lastPathComponent

        Task {
            self.cover = getCover()

            // 如果有大量的歌曲，就会产生大量的 updateMeta 操作，占内存较多
            if isDownloaded && !isCoverOnDisk() {
//                os_log("\(Logger.isMain)🍋 Audio::init 获取Meta \(self.title)")
                await updateMeta()
            }
        }
    }

    func getURL() -> URL {
        cacheURL ?? url
    }

    func getFileSize() -> Int64 {
        FileHelper.getFileSize(url)
    }

    func getFileSizeReadable() -> String {
        FileHelper.getFileSizeReadable(url)
    }

    func download() {
        SmartFile(url: url).download()
    }
}

extension Audio {
    static var emptyId = AppConfig.cloudDocumentsDir
    static var empty = Audio(emptyId)

    func isEmpty() -> Bool {
        id == Audio.emptyId
    }
}

extension Audio: Equatable {
    static func == (lhs: Audio, rhs: Audio) -> Bool {
        return lhs.url == rhs.url
    }
}

extension Audio: Identifiable {
    var id: URL { url }
}

// MARK: iCloud 相关

extension Audio {
    var isCached: Bool { cacheURL != nil }
    var isDownloaded: Bool { downloadingPercent == 100.0 }
    var isNotDownloaded: Bool { !isDownloaded }

    /// 准备好文件
    func prepare() {
        os_log("\(Logger.isMain)🔊 AudioModel::prepare -> \(self.title)")
        SmartFile(url: getURL()).download()
    }
}

// MARK: 删除

extension Audio {
    /// 删除多个文件
    static func delete(urls: Set<URL>) async {
        os_log("\(Logger.isMain)🏠 AudioModel::delete")
        AppConfig.mainQueue.async {
            for url in urls {
                Audio(url).delete()
            }
        }
    }

    func delete() {
        do {
            if fileManager.fileExists(atPath: url.path) {
                try fileManager.removeItem(at: url)
                SmartFile(url: url).delete()
            } else {
                os_log("\(Logger.isMain)删除时发现文件不存在，忽略 -> \(self.url.lastPathComponent)")
            }
        } catch {
            os_log(.error, "删除文件失败\n\(error)")
        }
    }
}

// MARK: Meta

extension Audio {
    var coverPath: URL {
        let fileName = url.lastPathComponent
        let imageName = fileName
        let coversDir = AppConfig.coverDir

        do {
            try fileManager.createDirectory(
                at: coversDir, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print(error.localizedDescription)
        }

        return
            coversDir
                .appendingPathComponent(imageName)
                .appendingPathExtension("jpeg")
    }

    func updateMeta() async {
        let asset = AVAsset(url: cacheURL ?? url)
        do {
            let metadata = try await asset.load(.commonMetadata)

            for item in metadata {
                do {
                    let value = try await item.load(.value)

                    switch item.commonKey?.rawValue {
                    case "title":
                        if let title = value as? String {
                            //                            os_log("\(Logger.isMain)🍋 AudioModel::updateMeta -> title: \(title)")
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

                        if (try makeImage(await item.load(.value), saveTo: coverPath)) != nil {
                            cover = coverPath
                            delegate.onCoverUpdated()
                            os_log("\(Logger.isMain)🍋 AudioModel::updateMeta -> cover updated -> \(self.title)")
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
        #if os(iOS)
            if let data = data as? Data, let image = UIImage(data: data) {
                return Image(uiImage: image)
            }
        #endif

        #if os(macOS)
            if fileManager.fileExists(atPath: saveTo.path) {
                guard let nsImage = NSImage(contentsOfFile: saveTo.path) else {
                    return nil
                }
                return Image(nsImage: nsImage)
            }
            if let data = data as? Data, let image = NSImage(data: data) {
                ImageHelper.toJpeg(image: image, saveTo: saveTo)
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
            UIImage(contentsOfFile: coverPath.path) ??
                UIImage(imageLiteralResourceName: "DefaultAlbum")
        }
    #endif

    func isCoverOnDisk() -> Bool {
        fileManager.fileExists(atPath: coverPath.path)
    }

    func getCover() -> URL? {
        if isNotDownloaded {
            return nil
        }

        if isCoverOnDisk() {
            return coverPath
        }

        return nil
    }
}

#Preview("App") {
    RootView {
        ContentView()
    }
}
