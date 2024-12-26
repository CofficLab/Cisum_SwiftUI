import Foundation
import SwiftUI

struct FileStatus: Identifiable {
    let id: UUID
    let name: String
    let status: Status
    let downloadStatus: DownloadStatus
    let url: URL?
    let isDirectory: Bool
    
    init(
        name: String,
        status: Status,
        downloadStatus: DownloadStatus,
        url: URL? = nil,
        isDirectory: Bool = false
    ) {
        self.id = UUID()
        self.name = name
        self.status = status
        self.downloadStatus = downloadStatus
        self.url = url
        self.isDirectory = isDirectory
    }
    
    enum Status: Equatable {
        case idle
        case pending
        case processing
        case completed
        case failed(String)
        
        var icon: String {
            switch self {
            case .idle, .pending: return "circle"
            case .processing: return "arrow.triangle.2.circlepath"
            case .completed: return "checkmark.circle.fill"
            case .failed: return "exclamationmark.circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .idle, .pending: return .secondary
            case .processing: return .accentColor
            case .completed: return .green
            case .failed: return .red
            }
        }
    }
    
    enum DownloadStatus: Equatable {
        case notDownloaded
        case checking
        case checkingDirectory(String, Int, Int)  // 目录名, 当前项目, 总项目数
        case downloading(progress: Double)
        case downloaded
        case local
        case directoryStatus(total: Int, downloaded: Int, downloading: Int, notDownloaded: Int)
        
        static func == (lhs: DownloadStatus, rhs: DownloadStatus) -> Bool {
            switch (lhs, rhs) {
            case (.notDownloaded, .notDownloaded):
                return true
            case (.checking, .checking):
                return true
            case (.checkingDirectory(let lhsName, let lhsCurrent, let lhsTotal),
                  .checkingDirectory(let rhsName, let rhsCurrent, let rhsTotal)):
                return lhsName == rhsName && lhsCurrent == rhsCurrent && lhsTotal == rhsTotal
            case (.downloading(let lhsProgress), .downloading(let rhsProgress)):
                return lhsProgress == rhsProgress
            case (.downloaded, .downloaded):
                return true
            case (.local, .local):
                return true
            case (.directoryStatus(let lhsTotal, let lhsDownloaded, let lhsDownloading, let lhsNotDownloaded),
                  .directoryStatus(let rhsTotal, let rhsDownloaded, let rhsDownloading, let rhsNotDownloaded)):
                return lhsTotal == rhsTotal &&
                       lhsDownloaded == rhsDownloaded &&
                       lhsDownloading == rhsDownloading &&
                       lhsNotDownloaded == rhsNotDownloaded
            default:
                return false
            }
        }
        
        var icon: String? {
            switch self {
            case .notDownloaded:
                return "icloud.and.arrow.down"
            case .checking, .checkingDirectory:
                return "arrow.triangle.2.circlepath"
            case .downloading:
                return "arrow.down.circle"
            case .downloaded, .local:
                return nil
            case .directoryStatus:
                return nil
            }
        }
        
        var color: Color {
            switch self {
            case .notDownloaded:
                return .secondary
            case .checking, .checkingDirectory:
                return .orange
            case .downloading:
                return .blue
            case .downloaded, .local:
                return .accentColor
            case .directoryStatus:
                return .accentColor
            }
        }
        
        var description: String {
            switch self {
            case .local:
                return "本地文件"
            case .downloaded:
                return "已下载"
            case .notDownloaded:
                return "未下载"
            case .downloading(let progress):
                return "下载中 \(Int(progress * 100))%"
            case .checking:
                return "检查中"
            case .checkingDirectory(let name, let current, let total):
                return "正在检查目录 \(name) (\(current)/\(total))"
            case .directoryStatus(let total, let downloaded, let downloading, let notDownloaded):
                var parts: [String] = []
                if downloaded > 0 {
                    parts.append("\(downloaded) 已下载")
                }
                if downloading > 0 {
                    parts.append("\(downloading) 下载中")
                }
                if notDownloaded > 0 {
                    parts.append("\(notDownloaded) 未下载")
                }
                return parts.isEmpty ? "空文件夹" : parts.joined(separator: ", ")
            }
        }
    }
    
    var icon: String {
        // 首先检查下载状态的图标
        if let downloadIcon = downloadStatus.icon, !downloadIcon.isEmpty {
            return downloadIcon
        }
        
        // 如果没有下载状态图标，则返回文件类型图标
        if isDirectory {
            // 检查是否为 iCloud 目录
            if let url = url,
               let values = try? url.resourceValues(forKeys: [.isUbiquitousItemKey]),
               values.isUbiquitousItem == true {
                return "icloud.fill"
            }
            return "folder.fill"
        }
        
        guard let url = url else { return "doc.fill" }
        
        // 文件类型图标
        switch url.pathExtension.lowercased() {
        case "mp3", "m4a", "wav", "aac":
            return "music.note"
        case "mp4", "mov", "avi", "mkv":
            return "film"
        case "jpg", "jpeg", "png", "gif":
            return "photo"
        case "pdf":
            return "doc.fill"
        case "txt", "md":
            return "doc.text.fill"
        default:
            return "doc.fill"
        }
    }
}
