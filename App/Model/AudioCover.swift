import Foundation
import SwiftUI
import OSLog
import AVKit

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

    #if os(iOS)
        func getUIImage() -> UIImage {
            // 要放一张正方形的图，否则会自动加上白色背景
            var i = UIImage(imageLiteralResourceName: "DefaultAlbum")
            if fileManager.fileExists(atPath: coverCacheURL.path) {
                i = UIImage(contentsOfFile: coverCacheURL.path) ?? i
            }

            return i
        }
    #endif

    func getCoverImage() async -> Image? {
         //os_log("\(Logger.isMain)🍋 Audio::getCoverImage for \(self.title)")
        guard let coverURL = await getCover() else {
            //os_log("\(Logger.isMain)🍋 Audio::getCoverImage for \(self.title) coverURL=nil give up")
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
