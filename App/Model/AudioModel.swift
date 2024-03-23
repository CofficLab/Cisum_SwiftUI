import AVFoundation
import Foundation
import SwiftUI

let emptyAudioModel = AudioModel(AppConfig.documentsDir)

enum iCloudState {
    case Downloaded
    case InCloud
    case Downloading
    case Uploading
    case Unknown

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
        default:
            return "未知状态"
        }
    }
}

struct AudioModel: Equatable, Identifiable {
    var id: URL {
        url
    }

    let url: URL
    var title: String = "[空白]"
    var artist: String = ""
    var description: String = ""
    var track: String = ""
    var albumName: String = ""
    var isEmpty: Bool = false
    var isDownloading: Bool = false
    var audioMeta: AudioMeta = AudioMeta()

    init(_ url: URL) {
        self.url = url
        title = url.deletingPathExtension().lastPathComponent
    }

    static func == (lhs: AudioModel, rhs: AudioModel) -> Bool {
        return lhs.url == rhs.url
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
        }
    }

    func getAudioMeta(_ completion: @escaping (_ audioMeta: AudioMeta) -> Void) {
        AudioMeta.fromUrl(url, completion: { audioMeta in
            completion(audioMeta)
        })
    }
}
