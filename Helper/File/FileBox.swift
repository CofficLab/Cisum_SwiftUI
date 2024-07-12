import Foundation
import OSLog
import SwiftUI
import AVKit

protocol FileBox: Identifiable {
    var url: URL { get }
}

extension FileBox {
    var label: String { "🎁 FileBox::" }
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

    func getFileSizeReadable(verbose: Bool = true) -> String {
        if verbose {
            os_log("\(self.label)GetFileSizeReadable for \(url.lastPathComponent)")
        }
        
        return FileHelper.getFileSizeReadable(getFileSize())
    }
    
    private func getFolderSize(_ url: URL) -> Int64 {
        var totalSize: Int64 = 0
        
        do {
            let fileManager = FileManager.default
            let contents = try  fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: [.fileSizeKey], options: .skipsHiddenFiles)
            
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
    var defaultImage: NSImage {
        NSImage(named: "DefaultAlbum")!
    }
    #else
    var defaultImage: UIImage {
        // 要放一张正方形的图，否则会自动加上白色背景
        UIImage(imageLiteralResourceName: "DefaultAlbum")
    }
    #endif

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

    func getCoverImage() async -> Image? {
        // os_log("\(self.label)getCoverImage for \(self.title)")

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

    func getCoverImageFromCache() -> Image? {
        // os_log("\(self.label)getCoverImageFromCache for \(self.title)")

        var url: URL? = coverCacheURL
        var fileManager = FileManager.default

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

    func getCoverFromMeta(verbose: Bool = true) async -> URL? {
        if verbose {
            // os_log("\(self.label)getCoverFromMeta for \(self.title)")
        }
        
        var fileManager = FileManager.default

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
            os_log(.error, "\(label)⚠️ 读取 Meta 出错 -> \(self.title)")
            os_log(.error, "\(error.localizedDescription)")
        }

        return nil
    }

    func getCoverFromMeta(_ callback: @escaping (_ url: URL?) -> Void, verbose: Bool = false, queue: DispatchQueue = .main) {
        if verbose {
            os_log("\(label)getCoverFromMeta for \(fileName)")
        }
        
        var fileManager = FileManager.default

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
            let asset = AVAsset(url: url)
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

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}
