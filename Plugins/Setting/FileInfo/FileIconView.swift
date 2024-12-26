import SwiftUI
import MagicKit

struct FileIconView: View {
    let url: URL
    let isDirectory: Bool
    let downloadStatus: FileStatus.DownloadStatus?
    let fileStatus: FileStatus?
    
    private var fileIcon: String {
        // 如果是目录，返回文件夹图标
        if isDirectory {
            // 检查是否为 iCloud 目录
            if let values = try? url.resourceValues(forKeys: [.isUbiquitousItemKey]),
               values.isUbiquitousItem == true {
                return "icloud.fill"
            }
            return "folder.fill"
        }
        
        // 根据文件扩展名返回对应图标
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
    
    private var statusIcon: String {
        if let status = downloadStatus {
            switch status {
            case .notDownloaded:
                return "icloud.and.arrow.down"
            case .checking, .checkingDirectory:
                return "arrow.triangle.2.circlepath"
            case .downloading:
                return "arrow.down.circle"
            case .downloaded, .local:
                return fileIcon
            case .directoryStatus:
                return fileIcon
            }
        }
        return fileIcon
    }
    
    var body: some View {
        Group {
            if let status = downloadStatus {
                switch status {
                case .local, .downloaded:
                    Image(systemName: statusIcon)
                        .foregroundColor(.accentColor)
                case .downloading:
                    Image(systemName: statusIcon)
                        .foregroundColor(status.color)
                        .if(fileStatus?.status == .processing) { view in
                            view.rotationEffect(.degrees(360))
                                .animation(
                                    .linear(duration: 1.0)
                                    .repeatForever(autoreverses: false),
                                    value: fileStatus?.status
                                )
                        }
                case .notDownloaded:
                    Image(systemName: statusIcon)
                        .foregroundColor(status.color)
                default:
                    Image(systemName: statusIcon)
                        .foregroundColor(status.color)
                }
            } else {
                Image(systemName: statusIcon)
                    .foregroundColor(.secondary)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: downloadStatus)
    }
} 