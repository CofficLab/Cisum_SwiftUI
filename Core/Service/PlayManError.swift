import Foundation

enum PlayManError: Error, LocalizedError {
    case NotDownloaded
    case DownloadFailed
    case Downloading
    case NotFound
    case NoChildren
    case NoAsset
    case FormatNotSupported(String)

    var errorDescription: String? {
        switch self {
        case .NotDownloaded:
            return "未下载"
        case .DownloadFailed:
            return "下载失败"
        case .Downloading:
            return "正在下载"
        case .NotFound:
            return "未找到"
        case .NoChildren:
            return "没有子项"
        case let .FormatNotSupported(ext):
            return "格式不支持 \(ext)"
        case .NoAsset:
            return "没有资源"
        }
    }
}
