import AVKit
import Foundation
import OSLog
import SwiftUI

extension Audio {
    #if os(macOS)
        static var defaultImage = NSImage(named: "DefaultAlbum")!
    #else
        // 要放一张正方形的图，否则会自动加上白色背景
        static var defaultImage = UIImage(imageLiteralResourceName: "DefaultAlbum")
    #endif

    var coverCacheURL: URL {
        let fileName = url.lastPathComponent
        let imageName = fileName
        let coversDir = AppConfig.coverDir

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

    func getImage<T>() -> T {
        var i: Any = Audio.defaultImage
        if fileManager.fileExists(atPath: coverCacheURL.path) {
            #if os(macOS)
                i = NSImage(contentsOf: coverCacheURL) ?? i
            #else
                i = UIImage(contentsOfFile: coverCacheURL.path) ?? i
            #endif
        }

        return i as! T
    }

    func getCoverImage() async -> Image? {
        // os_log("\(Logger.isMain)🍋 Audio::getCoverImage for \(self.title)")
        guard let coverURL = await getCover() else {
            // os_log("\(Logger.isMain)🍋 Audio::getCoverImage for \(self.title) coverURL=nil give up")
            return nil
        }

        #if os(macOS)
            if let nsImage = NSImage(contentsOf: coverURL) {
                return Image(nsImage: nsImage)
            } else {
                return nil
            }
        #else
            return Image(uiImage: UIImage(contentsOfFile: coverURL.path)!)
        #endif
    }

    func getCover() async -> URL? {
        // os_log("\(Logger.isMain)🍋 Audio::getCover for \(self.title)")

//        if isNotDownloaded {
//            return nil
//        }

        if fileManager.fileExists(atPath: coverCacheURL.path) {
            return coverCacheURL
        }

        let asset = AVAsset(url: url)
        do {
            let metadata = try await asset.load(.commonMetadata)

            for item in metadata {
                switch item.commonKey?.rawValue {
                case "artwork":
                    if try (makeImage(await item.load(.value), saveTo: coverCacheURL)) != nil {
                        // os_log("\(Logger.isMain)🍋 AudioModel::updateMeta -> cover updated -> \(self.title)")
                        return coverCacheURL
                    }
                default:
                    break
                }
            }
        } catch {
            // os_log("\(Logger.isMain)⚠️ 读取 Meta 出错\(error)")
        }

        return nil
    }
}
