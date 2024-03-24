import AVFoundation
import Foundation
import OSLog
import SwiftUI

class AudioModel {
    let fileManager = FileManager.default
    let url: URL
    var cacheURL: URL? = nil
    var title = "[空白]"
    var artist = ""
    var description = ""
    var track = ""
    var albumName = ""
    var isDownloading = false
    var delegate: SuperAudioDelegate
    #if os(macOS)
        var cover = Image(nsImage: NSImage(imageLiteralResourceName: "DefaultAlbum"))
    #else
        var image: Image = Image(uiImage: UIImage(imageLiteralResourceName: "DefaultAlbum"))
        var uiImage: UIImage = UIImage(imageLiteralResourceName: "DefaultAlbum")
    #endif

    init(_ url: URL, cacheURL: URL? = nil, delegate: SuperAudioDelegate = SuperAudioDelegateSample()) {
        os_log("🚩 AudioModel::init -> \(url.lastPathComponent)")
        self.url = url
        self.cacheURL = cacheURL
        self.delegate = delegate
        self.title = url.deletingPathExtension().lastPathComponent
        
        Task {
            await makeMeta();
        }
    }

    func getIcon() -> Image {
        switch getiCloudState() {
        case .Downloaded:
            return Image(systemName: "icloud")
        case .Downloading:
            return Image(systemName: "square.and.arrow.down")
        case .InCloud:
            return Image(systemName: "icloud.and.arrow.down")
        case .Uploading:
            return Image(systemName: "icloud.and.arrow.up")
        case .Unknown:
            return Image(systemName: "music.note")
        case .Cached:
            return Image(systemName: "icloud")
        }
    }
}

extension AudioModel {
    static var emptyId = AppConfig.documentsDir
    static var empty = AudioModel(emptyId)

    func isEmpty() -> Bool {
        id == AudioModel.emptyId
    }
}

extension AudioModel: Equatable {
    static func == (lhs: AudioModel, rhs: AudioModel) -> Bool {
        return lhs.url == rhs.url
    }
}

extension AudioModel: Identifiable {
    var id: URL { url }
}

// MARK: iCloud 相关

extension AudioModel {
    func getiCloudState() -> iCloudState {
        if url.pathExtension == "downloading" {
            return .Downloading
        }

        let status = iCloudHelper.getDownloadingStatus(url: url)

        switch status {
        case .current:
            return .Downloaded
        case .downloaded:
            return .Downloaded
        case .notDownloaded:
            return .Downloading
        default:
            return .Unknown
        }
    }

    enum iCloudState {
        case Downloaded
        case InCloud
        case Downloading
        case Uploading
        case Unknown
        case Cached

        var description: String {
            switch self {
            case .Downloaded:
                return "已下载"
            case .InCloud:
                return "在iCloud中"
            case .Downloading:
                return "下载中"
            case .Unknown:
                return "未知状态"
            case .Cached:
                return "已缓存"
            default:
                return "未知状态"
            }
        }
    }
}

// MARK: 删除

extension AudioModel {
    func delete() {
        do {
            if fileManager.fileExists(atPath: url.path) {
                try fileManager.removeItem(at: url)
            } else {
                os_log("删除时发现文件不存在，忽略 -> \(self.url.lastPathComponent)")
            }
        } catch {
            os_log(.error, "删除文件失败\n\(error)")
        }
    }
}

// MARK: Meta

extension AudioModel {
    var coverPath: URL {
        let fileName = url.lastPathComponent
        let imageName = fileName
        let coversDir = AppConfig.coverDir
        
        do {
          try fileManager.createDirectory(at: coversDir, withIntermediateDirectories: true, attributes: nil)
        } catch {
          print(error.localizedDescription)
        }

        return coversDir
            .appendingPathComponent(imageName)
            .appendingPathExtension("jpeg")
    }
    
    func makeMeta() async {
        let asset = AVAsset(url: url)
        do {
            let metadata = try await asset.load(.commonMetadata)

            for item in metadata {
                do {
                    let value = try await item.load(.value)

                    switch item.commonKey?.rawValue {
                    case "title":
                        if let title = value as? String {
                            os_log("从meta中读取的title: \(title, privacy: .public)")
                            self.title = title
                        } else {
                            os_log("meta提供了title，但value不能转成string")
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
                        if let image = makeImage(try await item.load(.value), saveTo: coverPath) {
                            self.cover = image
                            delegate.onCoverUpdated();
                        }
                    default:
                        break
                    }
                } catch {
                    os_log("读取 Meta 出错\n\(error)")
                }
            }
        } catch {
        }
    }

    func makeImage(_ data: (any NSCopying & NSObjectProtocol)?, saveTo: URL) -> Image? {
        #if os(iOS)
            if let data = data as? Data, let image = UIImage(data: data) {
                return Image(uiImage: image)
            }
        #endif

        #if os(macOS)
            if FileManager.default.fileExists(atPath: saveTo.path) {
                return Image(nsImage: NSImage(contentsOfFile: saveTo.path)!)
            }
            if let data = data as? Data, let image = NSImage(data: data) {
                ImageHelper.toJpeg(image: image, saveTo: saveTo)
                return Image(nsImage: image)
            }
        #endif

        return nil
    }
}

#Preview("App") {
    RootView {
        ContentView(play: false)
    }
}
