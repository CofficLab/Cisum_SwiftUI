import Foundation
import SwiftUI
import OSLog
import AVKit

struct DiskFile: FileBox, Hashable, Identifiable, Playable {
    static var home: DiskFile = DiskFile(url: URL.homeDirectory)
    static var label = "👶 DiskFile::"
    
    var fileManager = FileManager.default
    var id: URL { url }
    var url: URL
    var isDownloading: Bool = false
    var isUpdated: Bool = false
    var isDeleted: Bool = false
    var isDownloaded: Bool = true
    var downloadProgress: Double = 1.0
    var index: Int = 0
    var contentType: String?
    var size: Int64?

    var label: String {
        "\(Logger.isMain)\(Self.label)"
    }
}

extension DiskFile {
    func toAudio(verbose: Bool = false) -> Audio {
        if verbose {
            os_log("\(self.label)ToAudio: size(\(size.debugDescription))")
        }
        
        return Audio(url, size: size)
    }

    static func fromURL(_ url: URL) -> Self {
        DiskFile(url: url, isDownloading: false, downloadProgress: 1)
    }

    static func fromMetaWrapper(_ meta: MetaWrapper, verbose: Bool = false) -> Self {
        if verbose {
            os_log("\(Self.label)FromMetaWrapper -> \(meta.url?.path ?? "-") -> \(meta.downloadProgress)")
        }
        
        return DiskFile(
            url: meta.url!,
            isDownloading: meta.isDownloading,
            isDeleted: meta.isDeleted,
            downloadProgress: meta.downloadProgress,
            size: meta.fileSize
        )
    }
}

// MARK: OnChage

extension DiskFile {
    func onChange(_ callback: @escaping () -> Void) {
        let presenter = FilePresenter(fileURL: self.url)
        
        presenter.onDidChange = {
            os_log("\(self.label)变了 -> \(url.lastPathComponent)")
            
            callback()
        }
    }
}

// MARK: Children

extension DiskFile {
    var children: [DiskFile]? {
        getChildren()
    }
    
    func getChildren() -> [DiskFile]? {
        let fileManager = FileManager.default

        do {
            var files = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: [.nameKey], options: .skipsHiddenFiles)

            files.sort { $0.lastPathComponent < $1.lastPathComponent }

            let children: [DiskFile] = files.map { DiskFile(url: $0) }

            return children.isEmpty ? nil : children
        } catch {
            return nil
        }
    }
}

// MARK: Next

extension DiskFile {
    func next(verbose: Bool = false) -> DiskFile? {
        if verbose {
            os_log("\(label)Next of \(fileName)")
        }

        guard let parent = parent, let siblings = parent.getChildren() else {
            os_log("\(label)Next of \(fileName) -> nil")

            return nil
        }

        guard let index = siblings.firstIndex(of: self) else {
            return nil
        }
        
        guard siblings.count > self.index + 1 else {
            os_log("\(label)Next of \(fileName) -> nil")

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

extension DiskFile {
    func prev() -> DiskFile? {
        let prev: DiskFile? = nil

        os_log("\(label)Prev of \(fileName)")

        guard let parent = parent, let siblings = parent.getChildren() else {
            os_log("\(label)Prev of \(fileName) -> nil")

            return prev
        }
        
        guard let index = siblings.firstIndex(of: self) else {
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

// MARK: Parent

extension DiskFile {
    var parent: DiskFile? {
        guard let parentURL = url.deletingLastPathComponent() as URL? else {
            return nil
        }

        return DiskFile.fromURL(parentURL)
    }
}

// MARK: Tramsform

extension DiskFile {
    func toPlayAsset() -> PlayAsset {
        PlayAsset(url: url)
    }
}

extension DiskFile {
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
        let coversDir = Config.coverDir

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
        // os_log("\(self.label)getCoverImageFromCache for \(self.title)")

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

    // MARK: 从Meta读取

    func getCoverFromMeta(verbose: Bool = true) async -> URL? {
        if verbose {
            // os_log("\(self.label)getCoverFromMeta for \(self.title)")
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
            os_log(.error, "\(label)⚠️ 读取 Meta 出错")
            os_log(.error, "\(error.localizedDescription)")
        }

        return nil
    }

    func getCoverFromMeta(_ callback: @escaping (_ url: URL?) -> Void, verbose: Bool = false, queue: DispatchQueue = .main) {
        if verbose {
            os_log("\(label)getCoverFromMeta for \(fileName)")
        }

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

// MARK: 控制中心的图

extension DiskFile {
    func getMediaCenterImage<T>() -> T {
        var i: Any = DiskFile.defaultImage
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
