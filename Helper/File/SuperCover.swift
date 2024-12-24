import AVKit
import Foundation
import OSLog
import SwiftUI
import MagicKit

protocol SuperCover: Identifiable, SuperLog, FileBox {
    var url: URL { get }
    var coverFolder: URL { get }
}

extension SuperCover {
    static var emoji: String { "🎁" }
}

// MARK: Meta

extension SuperCover {
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

// MARK: Icon

extension SuperCover {
    var icon: String {
        isFolder() ? "folder" : "doc.text"
    }

    var image: Image {
        Image(systemName: icon)
    }
}

// MARK: 封面图

extension SuperCover {
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

    var coverCacheURL: URL? {
        let fileName = url.lastPathComponent
        let imageName = fileName
        let coversDir = self.coverFolder
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

    func getCoverImage(verbose: Bool = false) async throws -> Image? {
        if verbose {
            os_log("\(self.t)GetCoverImage for \(self.title)")
        }

        if let image = getCoverImageFromCache() {
            return image
        }

        let url = try await getCoverFromMeta()

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
            os_log("\(self.t)GetCoverImageFromCache for \(self.title)")
        }

        let url: URL? = coverCacheURL
        let fileManager = FileManager.default
        
        guard let url = url else {
            return nil
        }

        if !fileManager.fileExists(atPath: url.path) {
            return nil
        }

        #if os(macOS)
            if let nsImage = NSImage(contentsOf: url) {
                return Image(nsImage: nsImage)
            } else {
                return nil
            }
        #else
            return Image(uiImage: UIImage(contentsOfFile: url!.path)!)
        #endif
    }

    // MARK: 从Meta读取封面图

    func getCoverFromMeta(verbose: Bool = false) async throws -> URL? {
        guard let coverCacheURL = coverCacheURL else {
            os_log(.error, "\(self.t)coverCacheURL is nil")
            throw SuperCoverError.coverCacheURLNotFound
        }

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
            os_log("\(self.t)GetCoverFromMeta for \(self.title)")
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
                        os_log("\(self.t)Cover updated for \(self.title)")
                    }
                    return coverCacheURL
                }
            }
        } catch {
            os_log(.error, "\(t)⚠️ Error reading metadata for \(self.title): \(error.localizedDescription)")
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
            os_log("\(self.t)GetCoverFromMeta for \(self.title)")
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
                os_log(.error, "\(t)⚠️ Error reading metadata for \(self.title): \(error.localizedDescription)")
                os_log(.error, "  ➡️ \(self.url.relativeString)")
            }
        }

        return nil
    }

    func getCoverFromMeta(_ callback: @escaping (_ url: URL?) -> Void, verbose: Bool = false, queue: DispatchQueue = .main) {
        if verbose {
            os_log("\(t)getCoverFromMeta for \(fileName)")
        }

        let fileManager = FileManager.default

        if isNotDownloaded {
            return queue.async {
                callback(nil)
            }
        }

        if let coverCacheURL = coverCacheURL, fileManager.fileExists(atPath: coverCacheURL.path) {
            return queue.async {
                callback(coverCacheURL)
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
                        guard let coverCacheURL = coverCacheURL else {
                            os_log(.error, "\(self.t)coverCacheURL is nil")
                            return queue.async {
                                callback(nil)
                            }
                        }

                        if try (makeImage(await item.load(.value), saveTo: coverCacheURL)) != nil {
                            if verbose {
                                os_log("\(self.t)cover updated -> \(self.fileName)")
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
                os_log(.error, "\(self.t)⚠️ 读取 Meta 出错 -> \(error.localizedDescription)")
                os_log(.error, "\(error)")
            }

            queue.async {
                callback(nil)
            }
        }
    }
}

enum SuperCoverError: Error {
    case coverCacheURLNotFound
}
