import SwiftUI
import OSLog
import AVKit

struct PlayAsset {
    static var label = "🪖 PlayAsset::"
    
    var url: URL
    var contentType: String?
    var like: Bool = false
    var label: String { "\(Logger.isMain)\(Self.label)" }
    let fileManager = FileManager.default
    
    var title: String { url.lastPathComponent }
    var ext: String { url.pathExtension }
    
    // 未解决的问题：ios上文件APP中能看到，但FileManager.default.exits返回false
    func isExists() -> Bool {
        fileManager.fileExists(atPath: url.path)
    }
    
    func isNotExists() -> Bool {
        !isExists()
    }
    
    func isDownloading() -> Bool {
        iCloudHelper.isDownloading(self.url)
    }
    
    func isDownloaded() -> Bool {
        iCloudHelper.isDownloaded(url: self.url)
    }
    
    func isNotDownloaded() -> Bool {
        !isDownloaded()
    }
    
    func isSupported() -> Bool {
        AppConfig.supportedExtensions.contains(ext.lowercased())
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
}

extension PlayAsset {
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

// MARK: 封面图

func getCoverImageFromCache() -> Image? {
    //os_log("\(self.label)getCoverImageFromCache for \(self.title)")

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
    //os_log("\(self.label)getCoverImage for \(self.title)")

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

// MARK: 从Meta读取

func getCoverFromMeta(verbose: Bool = true) async -> URL? {
    if verbose {
        //os_log("\(self.label)getCoverFromMeta for \(self.title)")
    }

    if self.isNotDownloaded() {
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
        os_log(.error, "\(self.label)⚠️ 读取 Meta 出错")
        os_log(.error, "\(error.localizedDescription)")
    }

    return nil
}

func getCoverFromMeta(_ callback: @escaping (_ url: URL?) -> Void, verbose: Bool = false, queue: DispatchQueue = .main) {
    if verbose {
        os_log("\(self.label)getCoverFromMeta for \(self.title)")
    }

    if self.isNotDownloaded() {
        return queue.async {
            callback(nil)
        }
    }

    if fileManager.fileExists(atPath: coverCacheURL.path) {
        return queue.async {
            callback(self.coverCacheURL)
        }
    }
    
    if let contentType = contentType, !FileHelper.isAudioFile(contentType) {
        return queue.async {
            callback(nil)
        }
    }

    Task {
        let asset = AVAsset(url: url)
        do {
            let metadata = try await asset.load(.commonMetadata)

            for item in metadata {
                switch item.commonKey?.rawValue {
                case "artwork":
                    if try (makeImage(await item.load(.value), saveTo: coverCacheURL)) != nil {
                        if verbose {
                            os_log("\(self.label)cover updated -> \(self.title)")
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

#Preview {
    AppPreview()
}
