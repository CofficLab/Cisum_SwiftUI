import Foundation
import SwiftUI

enum SmartError: Error, LocalizedError {
    case NoDownloadedAudio
    case NoNextDownloadedAudio
    case NoNextAudio
    case NoPrevAudio
    case NoAudioInList
    case NotDownloaded
    case TargetNotFoundInPlaylist
    case Downloading
    case FormatNotSupported(_ format: String)
    case PlayFailed
    case NetworkError
    
    var errorDescription: String? {
        switch self {
        case .NoDownloadedAudio:
            "所有文件都在从 iCloud 下载，暂不能播放"
        case .NoNextDownloadedAudio:
            "其他文件都在从 iCloud 下载，暂不能播放"
        case .NoNextAudio:
            "曲库仅此一首，无下一首"
        case .NoPrevAudio:
            "曲库仅此一首，无上一首"
        case .NoAudioInList:
            "无可播放的歌曲"
        case .Downloading:
            "正在从 iCloud 下载"
        case .FormatNotSupported(let format):
            "不支持这个格式： \(format)"
        case .PlayFailed:
            "出现系统错误，播放失败"
        case .TargetNotFoundInPlaylist:
            "播放列表中找不到这个音频"
        case .NotDownloaded:
            "当前歌曲未下载"
        case .NetworkError:
            "网络未连接"
        }
    }
}

#Preview {
    RootView {
        ContentView()
    }
}
