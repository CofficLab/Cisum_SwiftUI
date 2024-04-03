import AVFoundation
import Foundation
import OSLog
import SwiftUI
import SwiftData

/**
 Audio 来自 DB，代表一个可播放的个体
 */

@Model
class Audio {
    @Transient let fileManager = FileManager.default
    var url: URL
    var title = "[空白]"
    var artist = ""
    var track = ""
    var albumName = ""
    var coverURL: URL?
    var downloadingPercent: Double = 0
    var isDownloading: Bool = false
    var isPlaceholder: Bool = false
    var size: Int64 { getFileSize() }

    init(_ url: URL) {
        // os_log("\(Logger.isMain)🚩 AudioModel::init -> \(url.lastPathComponent)")
        self.url = url
        self.title = url.deletingPathExtension().lastPathComponent
        self.coverURL = getCover()

        Task {
            // 如果有大量的歌曲，就会产生大量的 updateMeta 操作，占内存较多
            if isDownloaded && !isCoverOnDisk() {
                //os_log("\(Logger.isMain)🍋 Audio::init 获取Meta \(self.title)")
                await updateMeta()
            }
        }
    }

    func getFileSize() -> Int64 {
        FileHelper.getFileSize(url)
    }

    func getFileSizeReadable() -> String {
        FileHelper.getFileSizeReadable(url)
    }

    func refresh() {}
}

// MARK: 比较

extension Audio: Equatable {
    static func == (lhs: Audio, rhs: Audio) -> Bool {
        return lhs.url == rhs.url &&
            lhs.isDownloading == rhs.isDownloading &&
            lhs.downloadingPercent == rhs.downloadingPercent &&
            lhs.coverURL == rhs.coverURL
    }
}

// MARK: ID

extension Audio: Identifiable {
    var id: URL { url }
}

// MARK: iCloud 相关

extension Audio {
    var isDownloaded: Bool { downloadingPercent == 100.0 || !isPlaceholder }
    var isNotDownloaded: Bool { !isDownloaded }

    /// 准备好文件
    func prepare() {
        os_log("\(Logger.isMain)🔊 AudioModel::prepare -> \(self.title)")
        download()
    }

    func download() {
//        db.download(url)
    }
}

// MARK: 删除

extension Audio {
    func delete() {
//        db.delete(self)
    }
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

                        if try (makeImage(await item.load(.value), saveTo: coverCacheURL)) != nil {
                            coverURL = coverCacheURL
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

    func isCoverOnDisk() -> Bool {
        fileManager.fileExists(atPath: coverCacheURL.path)
    }

    func getCover() -> URL? {
        if isNotDownloaded {
            return nil
        }

        if isCoverOnDisk() {
            return coverCacheURL
        }

        return nil
    }
}

// MARK: Print

extension Audio {
    func debugPrint() {
        print("url: \(url)")
        print("title: \(title)")
        print("artist: \(artist)")
        print("track: \(track)")
        print("albumName: \(albumName)")
        print("coverURL: \(String(describing: coverURL))")
        print("downloadingPercent: \(downloadingPercent)")
        print("isDownloading: \(isDownloading)")
        print("isPlaceholder: \(isPlaceholder)")
        print("size: \(size)")
    }
}

#Preview("App") {
    RootView {
        ContentView()
    }
}
