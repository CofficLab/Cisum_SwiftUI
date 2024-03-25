import Foundation

enum SmartError: Error, LocalizedError {
    case NoDownloadedAudio
    
    var errorDescription: String? {
        switch self {
        case .NoDownloadedAudio:
            "所有文件都在从 iCloud 下载，暂不能播放"
        }
    }
}
