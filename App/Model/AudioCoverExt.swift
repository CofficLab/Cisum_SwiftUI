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

    // MARK: 图片的储存路径

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

    // MARK: 控制中心的图

    func getMediaCenterImage<T>() -> T {
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

    // MARK: 封面图
    
    func getCoverImageFromCache() -> Image? {
        os_log("\(self.label)getCoverImageFromCache for \(self.title)")

        var url: URL? = coverCacheURL
        
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

    func getCoverImage() async -> Image? {
        os_log("\(self.label)getCoverImage for \(self.title)")

        let url =  await getCoverFromMeta()
        
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

    // MARK: 从Meta读取

    func getCoverFromMeta(verbose: Bool = true) async -> URL? {
        if verbose {
            os_log("\(self.label)getCoverFromMeta for \(self.title)")
        }

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
            os_log(.error, "\(self.label)⚠️ 读取 Meta 出错\(error)")
        }

        return nil
    }
}
