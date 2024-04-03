import Foundation
import SwiftData
import SwiftUI
import AVKit
import AVFoundation
import OSLog

@Model
class PlayItem {
    @Transient var fileManager = FileManager.default
    
    var url: URL
    var order: Int = 0
    var title: String  = ""
    var artist: String = ""
    var albumName: String = ""
    var coverURL: URL? = nil
    var downloadingPercent: Double = 0
    var isDownloading: Bool = false
    var isPlaceholder: Bool = false
    
    var isNotDownloaded: Bool { isDownloading || downloadingPercent < 100 || isPlaceholder}
    
    init(_ url: URL, order: Int = 0) {
        self.url = url
        self.order = order
        self.title = url.lastPathComponent
    }
}

// MARK: 增删改查

extension PlayItem {
    // MARK: 查找
    
    static func find(_ context: ModelContext, url: URL) -> PlayItem? {
        let predicate = #Predicate<PlayItem> {
            $0.url == url
        }
        var descriptor = FetchDescriptor<PlayItem>(predicate: predicate)
        descriptor.fetchLimit = 1
        do {
            let result = try context.fetch(descriptor)
            if let first = result.first {
                return first
            } else {
                print("not found")
            }
        } catch let e{
            print(e)
        }
        
        return nil
    }
    
    static func find(_ context: ModelContext, index: Int) -> PlayItem? {
        var descriptor = FetchDescriptor<PlayItem>()
        descriptor.fetchLimit = 1 // 限制查询结果为1条记录
        descriptor.fetchOffset = index // 设置偏移量，从0开始
        do {
            let result = try context.fetch(descriptor)
            if let first = result.first {
                return first
            } else {
                print("not found")
            }
        } catch let e{
            print(e)
        }
        
        return nil
    }
    
    static func nextOf(_ context: ModelContext, item: Audio) -> PlayItem? {
        if let current = find(context, url: item.url) {
            print(current.id)
        }
        
        return nil
    }
    
    static func nextOf(_ context: ModelContext, item: PlayItem) -> PlayItem? {
        let id = item.persistentModelID
        let predicate = #Predicate<PlayItem> {
            $0.persistentModelID > id
        }
        var descriptor = FetchDescriptor<PlayItem>(predicate: predicate)
        descriptor.fetchLimit = 1
        do {
            let result = try context.fetch(descriptor)
            if let first = result.first {
                return first
            } else {
                print("not found")
            }
        } catch let e{
            print(e)
        }
        
        return nil
    }
}

// MARK: Meta

extension PlayItem {
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

    func updateMeta() async {
        let asset = AVAsset(url: url)
        do {
            let metadata = try await asset.load(.commonMetadata)

            for item in metadata {
                do {
                    let value = try await item.load(.value)

                    switch item.commonKey?.rawValue {
                    case "title":
                        if let title = value as? String {
                            // os_log("\(Logger.isMain)🍋 AudioModel::updateMeta -> title: \(title)")
                            self.title = title
                        } else {
                            os_log("\(Logger.isMain)meta提供了title，但value不能转成string")
                        }
                    case "artist":
                        if let artist = value as? String {
                            self.artist = artist
                        }
                    case "albumName":
                        if let albumName = value as? String {
                            self.albumName = albumName
                        }
                    case "artwork":

                        // MARK: 得到了封面图

                        if try (makeImage(await item.load(.value), saveTo: coverCacheURL)) != nil {
                            coverURL = coverCacheURL
//                            os_log("\(Logger.isMain)🍋 AudioModel::updateMeta -> cover updated -> \(self.title)")
                        }
                    default:
                        break
                    }
                } catch {
                    os_log("\(Logger.isMain)读取 Meta 出错\n\(error)")
                }
            }
        } catch {}
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
}

// MARK: Cover

extension PlayItem {
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
