import Foundation

enum SmartError: Error, LocalizedError {
    case NoDownloadedAudio
    case NoNextDownloadedAudio
    case NoNextAudio
    case NoPrevAudio
    
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
        }
    }
}
