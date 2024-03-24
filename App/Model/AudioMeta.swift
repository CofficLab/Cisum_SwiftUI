import AVFoundation
import Foundation
import SwiftUI
import OSLog

struct AudioMeta {
    var fileManager = FileManager.default
    var title: String = ""
    var artist: String = ""
    var albumName: String = ""
    #if os(macOS)
        var image: Image = Image(nsImage: NSImage(imageLiteralResourceName: "DefaultAlbum"))
    #else
        var image: Image = Image(uiImage: UIImage(imageLiteralResourceName: "DefaultAlbum"))
        var uiImage: UIImage = UIImage(imageLiteralResourceName: "DefaultAlbum")
    #endif

    static func fromUrl(_ url: URL, completion: @escaping (_ audioMeta: AudioMeta) -> Void) {
        Task {
            var audioMeta = AudioMeta()
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
                                audioMeta.title = title
                            } else {
                                os_log("meta提供了title，但value不能转成string")
                            }
                        case "artist":
                            if let artist = value as? String {
                                audioMeta.artist = artist
                            }
                        case "albumName":
                            if let albumName = value as? String {
                                audioMeta.albumName = albumName
                            }
                        case "artwork":
                            if let image = makeImage(try await item.load(.value), saveTo: coverSavedPath(url)) {
                                audioMeta.image = image
                            }
                        default:
                            break
                        }
                    } catch {
                        os_log("读取 Meta 出错\n\(error)")
                    }
                }

                completion(audioMeta)
            } catch {
                completion(audioMeta)
            }
        }
    }

    #if os(iOS)
        private static func makeUIImage(_ data: (any NSCopying & NSObjectProtocol)?) -> UIImage? {
            if let data = data as? Data, let image = UIImage(data: data) {
                return image
            }

            return nil
        }
    #endif

    private static func makeImage(_ data: (any NSCopying & NSObjectProtocol)?, saveTo: URL) -> Image? {
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

    private static func coverSavedPath(_ url: URL) -> URL {
        let fileName = url.lastPathComponent
        let imageName = fileName
        let coversDir = AppManager.iCloudDocumentsUrl!.appendingPathComponent(AppConfig.coversDirName)
        
        do {
          try FileManager.default.createDirectory(at: coversDir, withIntermediateDirectories: true, attributes: nil)
        } catch {
          print(error.localizedDescription)
        }

        return coversDir
            .appendingPathComponent(imageName)
            .appendingPathExtension("jpeg")
    }
}
