import AVKit
import Foundation
import OSLog
import SwiftUI

#if os(iOS) || os(visionOS)
import UIKit
typealias PlatformImage = UIImage
#elseif os(macOS)
import AppKit
typealias PlatformImage = NSImage
#endif

protocol FileBox: Identifiable {
    var url: URL { get }
}

extension FileBox {
    var label: String { "🎁 FileBox::" }
//    var backgroundQueue = DispatchQueue
}

// MARK: Meta

extension FileBox {
    var title: String { url.deletingPathExtension().lastPathComponent }
    var fileName: String { url.lastPathComponent }
    var ext: String { url.pathExtension }
    var contentType: String {
        do {
            let resourceValues = try url.resourceValues(forKeys: [.typeIdentifierKey])
            return resourceValues.contentType?.identifier ?? ""
        } catch {
            print("Error getting content type: \(error)")
            return ""
        }
    }

    var isImage: Bool {
        ["png", "jpg", "jpeg", "gif", "bmp", "webp"].contains(ext)
    }

    var isJSON: Bool {
        ext == "json"
    }

    var isWMA: Bool {
        ext == "wma"
    }
}

// MARK: FileSize

extension FileBox {
    func getFileSize() -> Int64 {
        if self.isNotFolder() {
            FileHelper.getFileSize(url)
        } else {
            getFolderSize(self.url)
        }
    }

    func getFileSizeReadable(verbose: Bool = false) -> String {
        if verbose {
            os_log("\(self.label)GetFileSizeReadable for \(url.lastPathComponent)")
        }

        return FileHelper.getFileSizeReadable(getFileSize())
    }

    private func getFolderSize(_ url: URL) -> Int64 {
        var totalSize: Int64 = 0

        do {
            let fileManager = FileManager.default
            let contents = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: [.fileSizeKey], options: .skipsHiddenFiles)

            for itemURL in contents {
                if itemURL.hasDirectoryPath {
                    totalSize += getFolderSize(itemURL)
                } else {
                    totalSize += FileHelper.getFileSize(itemURL)
                }
            }
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }

        return totalSize
    }
}

// MARK: Parent

extension FileBox {
    var parentURL: URL? {
        guard let parentURL = url.deletingLastPathComponent() as URL? else {
            return nil
        }

        return parentURL
    }
}

// MARK: Children

extension FileBox {
    var children: [URL]? {
        getChildren()
    }

    func getChildren() -> [URL]? {
        getChildrenOf(self.url)
    }

    func getChildrenOf(_ url: URL, verbose: Bool = false) -> [URL]? {
        if verbose {
            os_log("\(self.label)GetChildrenOf \(url.lastPathComponent)")
        }

        let fileManager = FileManager.default

        do {
            var files = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: [.nameKey], options: .skipsHiddenFiles)

            files.sort { $0.lastPathComponent < $1.lastPathComponent }

            return files.isEmpty ? nil : files
        } catch {
            return nil
        }
    }
}

// MARK: Next

extension FileBox {
    func next(verbose: Bool = false) -> URL? {
        if verbose {
            os_log("\(label)Next of \(fileName)")
        }

        guard let parent = parentURL, let siblings = getChildrenOf(parent) else {
            os_log("\(label)Next of \(fileName) -> nil")

            return nil
        }

        guard let index = siblings.firstIndex(of: self.url) else {
            return nil
        }

        guard siblings.count > index + 1 else {
            if verbose {
                os_log("\(label)Next of \(fileName) -> nil")
            }

            return nil
        }

        let nextIndex = index + 1
        if nextIndex < siblings.count {
            return siblings[nextIndex]
        } else {
            return nil // 已经是数组的最后一个元素
        }
    }
}

// MARK: Prev

extension FileBox {
    func prev() -> URL? {
        let prev: URL? = nil

        os_log("\(label)Prev of \(fileName)")

        guard let parent = parentURL, let siblings = getChildrenOf(parent) else {
            os_log("\(label)Prev of \(fileName) -> nil")

            return prev
        }

        guard let index = siblings.firstIndex(of: self.url) else {
            return nil
        }

        guard index - 1 >= 0 else {
            os_log("\(label)Prev of \(fileName) -> nil")

            return prev
        }

        let prevIndex = index - 1
        if prevIndex < siblings.count {
            return siblings[prevIndex]
        } else {
            return nil
        }
    }
}

// MARK: iCloud 相关

extension FileBox {
    var isDownloaded: Bool {
        isFolder() || iCloudHelper.isDownloaded(url)
    }

    var isDownloading: Bool {
        iCloudHelper.isDownloading(url)
    }

    var isNotDownloaded: Bool {
        !isDownloaded
    }

    var isiCloud: Bool {
        iCloudHelper.isCloudPath(url: url)
    }

    var isNotiCloud: Bool {
        !isiCloud
    }

    var isLocal: Bool {
        isNotiCloud
    }
}

// MARK: HASH

extension FileBox {
    func getHash(verbose: Bool = true) -> String {
        FileHelper.getMD5(self.url)
    }
}

// MARK: Exists

extension FileBox {
    func isExists(verbose: Bool = false) -> Bool {
        // iOS模拟器，如果是iCloud云盘地址且未下载，FileManager.default.fileExists会返回false

        if verbose {
            os_log("\(self.label)IsExists -> \(url.path)")
        }

        if iCloudHelper.isCloudPath(url: url) {
            return true
        }

        return FileManager.default.fileExists(atPath: url.path)
    }

    func isNotExists() -> Bool {
        !isExists()
    }
}

// MARK: isFolder

extension FileBox {
    func isFolder() -> Bool {
        FileHelper.isDirectory(at: self.url)
    }

    func isDirectory() -> Bool {
        isFolder()
    }

    func isNotFolder() -> Bool {
        !self.isFolder()
    }
}

// MARK: Icon

extension FileBox {
    var icon: String {
        isFolder() ? "folder" : "doc.text"
    }

    var image: Image {
        Image(systemName: icon)
    }
}

// MARK: Sub

extension FileBox {
    func inDir(_ dir: URL) -> Bool {
        FileHelper.isURLInDirectory(self.url, dir)
    }

    func has(_ url: URL) -> Bool {
        FileHelper.isURLInDirectory(url, self.url)
    }
}

// MARK: Format

extension FileBox {
    func isVideo() -> Bool {
        ["mp4"].contains(self.ext)
    }

    func isAudio() -> Bool {
        [".mp3", ".wav"].contains(self.ext)
    }

    func isNotAudio() -> Bool {
        !isAudio()
    }
}

// MARK: 封面图

extension FileBox {
    #if os(macOS)
        var defaultNSImage: NSImage {
            NSImage(named: "DefaultAlbum")!
        }
    #else
        var defaultUIImage: UIImage {
            // 要放一张正方形的图，否则会自动加上白色背景
            UIImage(imageLiteralResourceName: "DefaultAlbum")
        }
    #endif

    var defaultImage: Image {
        #if os(macOS)
            Image(nsImage: defaultNSImage)
        #else
            Image(uiImage: defaultUIImage)
        #endif
    }

    // MARK: 封面图的储存路径

    var coverCacheURL: URL {
        let fileName = url.lastPathComponent
        let imageName = fileName
        let coversDir = Config.coverDir
        let fileManager = FileManager.default

        do {
            try fileManager.createDirectory(
                at: coversDir, withIntermediateDirectories: true, attributes: nil)
        } catch {
            os_log(.error, "\(error.localizedDescription)")
        }

        return coversDir
            .appendingPathComponent(imageName)
            .appendingPathExtension("jpeg")
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
            os_log(.error, "\(e.localizedDescription)")
        }

        #if os(iOS)
            if let image = UIImage(data: data) {
                return Image(uiImage: image)
            }
        #elseif os(macOS)
            if let image = NSImage(data: data) {
                return Image(nsImage: image)
            }
        #endif

        return nil
    }

    // MARK: 获取封面图

    func getCoverImage(verbose: Bool = false) async -> Image? {
        if verbose {
            os_log("\(self.label)GetCoverImage for \(self.title)")
        }

        if let image = getCoverImageFromCache() {
            return image
        }

        let url = await getCoverFromMeta()

        guard let url = url else {
            return nil
        }

        #if os(macOS)
            if let nsImage = NSImage(contentsOf: url) {
                return Image(nsImage: nsImage)
            } else {
                return nil
            }
        #else
            return Image(uiImage: UIImage(contentsOfFile: url.path)!)
        #endif
    }

    // MARK: 从缓存读取封面图

    func getCoverImageFromCache(verbose: Bool = false) -> Image? {
        if verbose {
            os_log("\(self.label)GetCoverImageFromCache for \(self.title)")
        }

        var url: URL? = coverCacheURL
        let fileManager = FileManager.default

        if !fileManager.fileExists(atPath: url!.path) {
            return nil
        }

        #if os(macOS)
            if let nsImage = NSImage(contentsOf: url!) {
                return Image(nsImage: nsImage)
            } else {
                return nil
            }
        #else
            return Image(uiImage: UIImage(contentsOfFile: url!.path)!)
        #endif
    }

    // MARK: 从Meta读取封面图

    func getCoverFromMeta(verbose: Bool = false) async -> URL? {
        guard isDownloaded
            && !FileManager.default.fileExists(atPath: coverCacheURL.path)
            && !isFolder()
            && !isImage
            && !isJSON
            && !isWMA
        else {
            return isDownloaded ? coverCacheURL : nil
        }

        if verbose {
            os_log("\(self.label)GetCoverFromMeta for \(self.title)")
        }

        let asset = AVURLAsset(url: url)
        do {
            let commonMetadata = try await asset.load(.commonMetadata)
            let artworkItems = AVMetadataItem.metadataItems(
                from: commonMetadata,
                withKey: AVMetadataKey.commonKeyArtwork,
                keySpace: .common
            )
            if let artworkItem = artworkItems.first {
                let artworkData = try await artworkItem.load(.value)
                if makeImage(artworkData, saveTo: coverCacheURL) != nil {
                    if verbose {
                        os_log("\(self.label)Cover updated for \(self.title)")
                    }
                    return coverCacheURL
                }
            }
        } catch {
            os_log(.error, "\(label)⚠️ Error reading metadata for \(self.title): \(error.localizedDescription)")
            os_log(.error, "  ➡️ \(self.url.relativeString)")
        }

        return nil
    }
    
    func getCoverData(verbose: Bool = false) async -> Data? {
        guard isDownloaded
            && url.isFileExist()
            && !isFolder()
            && !isImage
            && !isJSON
            && !isWMA
        else {
            return nil
        }

        if verbose {
            os_log("\(self.label)GetCoverFromMeta for \(self.title)")
        }

        let asset = AVURLAsset(url: url)
        do {
            let commonMetadata = try await asset.load(.commonMetadata)
            let artworkItems = AVMetadataItem.metadataItems(
                from: commonMetadata,
                withKey: AVMetadataKey.commonKeyArtwork,
                keySpace: .common
            )
            
            if let artworkItem = artworkItems.first,
               let artworkData = try await artworkItem.load(.value) as? Data {
                return artworkData
            } else if let artworkItem = artworkItems.first,
                      let artworkImage = try await artworkItem.load(.value) as? PlatformImage {
                #if os(iOS)
                return artworkImage.pngData()
                #elseif os(macOS)
                return artworkImage.tiffRepresentation
                #endif
            }
        } catch {
            if verbose {
                os_log(.error, "\(label)⚠️ Error reading metadata for \(self.title): \(error.localizedDescription)")
                os_log(.error, "  ➡️ \(self.url.relativeString)")
            }
        }

        return nil
    }

    func getCoverFromMeta(_ callback: @escaping (_ url: URL?) -> Void, verbose: Bool = false, queue: DispatchQueue = .main) {
        if verbose {
            os_log("\(label)getCoverFromMeta for \(fileName)")
        }

        let fileManager = FileManager.default

        if isNotDownloaded {
            return queue.async {
                callback(nil)
            }
        }

        if fileManager.fileExists(atPath: coverCacheURL.path) {
            return queue.async {
                callback(self.coverCacheURL)
            }
        }

        if isNotAudio() {
            return queue.async {
                callback(nil)
            }
        }

        Task {
            let asset = AVURLAsset(url: url)
            do {
                let metadata = try await asset.load(.commonMetadata)

                for item in metadata {
                    switch item.commonKey?.rawValue {
                    case "artwork":
                        if try (makeImage(await item.load(.value), saveTo: coverCacheURL)) != nil {
                            if verbose {
                                os_log("\(self.label)cover updated -> \(self.fileName)")
                            }

                            return queue.async {
                                callback(self.coverCacheURL)
                            }
                        }
                    default:
                        break
                    }
                }
            } catch {
                os_log(.error, "\(self.label)⚠️ 读取 Meta 出错 -> \(error.localizedDescription)")
                os_log(.error, "\(error)")
            }

            queue.async {
                callback(nil)
            }
        }
    }
}
