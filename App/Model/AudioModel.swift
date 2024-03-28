import AVFoundation
import Foundation
import OSLog
import SwiftUI

class AudioModel {
  let fileManager = FileManager.default
  private let url: URL
  private var cacheURL: URL?
  var title = "[空白]"
  var artist = ""
  var description = ""
  var track = ""
  var albumName = ""
  var delegate: SuperAudioDelegate
  var cover: Image?

  init(_ url: URL, cacheURL: URL? = nil, delegate: SuperAudioDelegate = SuperAudioDelegateSample())
  {
    // os_log("\(Logger.isMain)🚩 AudioModel::init -> \(url.lastPathComponent)")
    self.url = url
    self.cacheURL = cacheURL
    self.delegate = delegate
    title = url.deletingPathExtension().lastPathComponent

    Task {
      self.cover = getCover()

      // 如果有大量的歌曲，就会产生大量的 updateMeta 操作，占内存较多
      if self.getCoverFromDisk() == nil {
        await updateMeta()
      }
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

  func getURL() -> URL {
    cacheURL ?? url
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
  var isCached: Bool { cacheURL != nil }
  var isDownloaded: Bool { getiCloudState() == .Downloaded }
  var isNotDownloaded: Bool { !isDownloaded }

  /// 准备好文件
  func prepare() {
    // os_log("\(Logger.isMain)🔊 AudioModel::prepare -> \(self.title)")
    SmartFile(url: getURL()).download {
      os_log("\(Logger.isMain)🔊 AudioModel::downloaded 🎉🎉🎉 -> \(self.title)")
    }
  }

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
  /// 删除多个文件
  static func delete(urls: Set<URL>) async {
    os_log("\(Logger.isMain)🏠 AudioModel::delete")
    AppConfig.mainQueue.async {
      for url in urls {
        AudioModel(url).delete()
      }
    }
  }

  func delete() {
    do {
      if fileManager.fileExists(atPath: url.path) {
        try fileManager.removeItem(at: url)
        SmartFile(url: url).delete()
      } else {
        os_log("\(Logger.isMain)删除时发现文件不存在，忽略 -> \(self.url.lastPathComponent)")
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
      try fileManager.createDirectory(
        at: coversDir, withIntermediateDirectories: true, attributes: nil)
    } catch {
      print(error.localizedDescription)
    }

    return
      coversDir
      .appendingPathComponent(imageName)
      .appendingPathExtension("jpeg")
  }

  func updateMeta() async {
    let asset = AVAsset(url: cacheURL ?? url)
    do {
      let metadata = try await asset.load(.commonMetadata)

      for item in metadata {
        do {
          let value = try await item.load(.value)

          switch item.commonKey?.rawValue {
          case "title":
            if let title = value as? String {
              //                            os_log("\(Logger.isMain)🍋 AudioModel::updateMeta -> title: \(title)")
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

            if let image = try makeImage(await item.load(.value), saveTo: coverPath) {
              cover = image
              delegate.onCoverUpdated()
              os_log("\(Logger.isMain)🍋 AudioModel::updateMeta -> cover updated -> \(self.title)")
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
    #if os(iOS)
      if let data = data as? Data, let image = UIImage(data: data) {
        return Image(uiImage: image)
      }
    #endif

    #if os(macOS)
      if fileManager.fileExists(atPath: saveTo.path) {
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

// MARK: Cover

extension AudioModel {
  func getCover() -> Image {
    if let cover = getCoverFromDisk() {
      return cover
    }

    if isNotDownloaded {
      return downloadingCover
    }

    return cover ?? defaultCover
  }

  var downloadingCover: Image {
    Image(systemName: "arrow.down.circle.dotted")
  }

  func getCoverFromDisk() -> Image? {
    if fileManager.fileExists(atPath: coverPath.path) {
      #if os(macOS)
        return Image(nsImage: NSImage(contentsOf: coverPath)!)
      #else
        return Image(uiImage: UIImage(contentsOfFile: coverPath.path())!)
      #endif
    }

    return nil
  }

  var defaultCover: Image {
    #if os(macOS)
      Image(nsImage: NSImage(imageLiteralResourceName: "DefaultAlbum"))
    #else
      Image(uiImage: UIImage(imageLiteralResourceName: "DefaultAlbum"))
    #endif
  }

  #if os(iOS)
    var uiImage: UIImage {
      UIImage(imageLiteralResourceName: "DefaultAlbum")
    }
  #endif
}

#Preview("App") {
  RootView {
    ContentView(play: false)
  }
}
