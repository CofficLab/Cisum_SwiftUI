import AVFoundation
import Foundation
import OSLog
import SwiftData
import SwiftUI

@Model
class Audio {
    @Transient let fileManager = FileManager.default

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
            // 如果有大量的歌曲，就会产生大量的 updateMeta 操作，占内存较多
            if isDownloaded && !isCoverOnDisk() {
                // os_log("\(Logger.isMain)🍋 Audio::init 获取Meta \(self.title)")
//                await updateMeta()
            }
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
    var isDownloaded: Bool { downloadingPercent == 100 }
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
