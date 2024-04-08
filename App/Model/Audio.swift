import AVFoundation
import Foundation
import OSLog
import SwiftData
import SwiftUI

@Model
class Audio {
    @Transient let fileManager = FileManager.default

    var url: URL
    var order: Int = Int.random(in: 0...500000000)
    var downloadingPercent: Double = 0
    var isPlaceholder: Bool = false
    var title: String = ""

    var size: Int64 { getFileSize() }
    var ext: String { url.pathExtension }
    var isSupported: Bool { AppConfig.supportedExtensions.contains(ext) }
    var isNotSupported: Bool { !isSupported }

    init(_ url: URL) {
        // os_log("\(Logger.isMain)🚩 AudioModel::init -> \(url.lastPathComponent)")
        self.url = url
        self.title = url.deletingPathExtension().lastPathComponent
    }

    func makeRandomOrder() {
        order = Int.random(in: 0...500000000)
    }

    func getFileSize() -> Int64 {
        FileHelper.getFileSize(url)
    }

    func getFileSizeReadable() -> String {
        FileHelper.getFileSizeReadable(url)
    }
    
    func mergeWith(_ item: MetadataItemWrapper) -> Audio {
        self.downloadingPercent = item.downloadProgress
        self.isPlaceholder = item.isPlaceholder
        
        return self
    }
    
    static func fromMetaItem(_ item: MetadataItemWrapper) -> Audio? {
        guard let url = item.url else {
            return nil
        }
        
        let audio = Audio(url)
        
        return audio.mergeWith(item)
    }
}

// MARK: ID

extension Audio: Identifiable {
    var id: PersistentIdentifier { self.persistentModelID }
}

// MARK: iCloud 相关

extension Audio {
    var isDownloaded: Bool { iCloudHelper.isDownloaded(url: url) }
    var isNotDownloaded: Bool { !isDownloaded }
    var isDownloading: Bool { iCloudHelper.isDownloading(url) }
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
        func getUIImage() -> UIImage {
            var i = UIImage(imageLiteralResourceName: "DefaultAlbum")
            if fileManager.fileExists(atPath: coverCacheURL.path) {
                i = UIImage(contentsOfFile: coverCacheURL.path) ?? i
            }

            return i
        }
    #endif

    func getCoverImage() async -> Image? {
        guard let coverURL = await getCover() else {
            return nil
        }

        #if os(macOS)
            return Image(nsImage: NSImage(contentsOf: coverURL)!)
        #else
            return Image(uiImage: UIImage(contentsOfFile: coverURL.path)!)
        #endif
    }

    func getCover() async -> URL? {
        //os_log("\(Logger.isMain)🍋 Audio::getCover for \(self.title)")
        
        if isNotDownloaded {
            return nil
        }

        if fileManager.fileExists(atPath: coverCacheURL.path) {
            return coverCacheURL
        }

        let asset = AVAsset(url: url)
        do {
            let metadata = try await asset.load(.commonMetadata)

            for item in metadata {
                let value = try await item.load(.value)

                switch item.commonKey?.rawValue {
                case "artwork":
                    if try (makeImage(await item.load(.value), saveTo: coverCacheURL)) != nil {
                        //os_log("\(Logger.isMain)🍋 AudioModel::updateMeta -> cover updated -> \(self.title)")
                        return coverCacheURL
                    }
                default:
                    break
                }
            }
        } catch {
            //os_log("\(Logger.isMain)⚠️ 读取 Meta 出错\(error)")
        }

        return nil
    }
}

#Preview("App") {
    RootView {
        ContentView()
    }
}
