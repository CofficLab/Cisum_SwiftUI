import Foundation
import SwiftUICore

struct FileStatus: Identifiable {
    let id = UUID()
    let name: String
    let status: Status
    let downloadStatus: DownloadStatus

    enum Status: Equatable {
        case pending
        case processing
        case completed
        case failed(String)

        static func == (lhs: Status, rhs: Status) -> Bool {
            switch (lhs, rhs) {
            case (.pending, .pending):
                return true
            case (.processing, .processing):
                return true
            case (.completed, .completed):
                return true
            case (.failed(let lhsMessage), .failed(let rhsMessage)):
                return lhsMessage == rhsMessage
            default:
                return false
            }
        }

        var icon: String {
            switch self {
            case .pending: return "circle"
            case .processing: return "arrow.triangle.2.circlepath"
            case .completed: return "checkmark.circle.fill"
            case .failed: return "exclamationmark.circle.fill"
            }
        }

        var color: Color {
            switch self {
            case .pending: return .secondary
            case .processing: return .accentColor
            case .completed: return .green
            case .failed: return .red
            }
        }
    }
    
    enum DownloadStatus: Equatable {
        case local       // 本地文件
        case downloaded  // 已从 iCloud 下载
        case notDownloaded  // 在 iCloud 中但未下载
        case downloading(Double)  // 正在从 iCloud 下载，包含下载进度
        case checking   // 正在检查状态
        case checkingDirectory(String, Int, Int)  // 正在检查目录（目录名，当前项，总项数）
        
        var icon: String {
            switch self {
            case .local, .downloaded:
                return ""
            case .notDownloaded:
                return "icloud.and.arrow.down"
            case .downloading:
                return "arrow.down.circle"
            case .checking:
                return "magnifyingglass"
            case .checkingDirectory:
                return "folder.badge.gearshape"
            }
        }
        
        var color: Color {
            switch self {
            case .local, .downloaded:
                return .clear
            case .notDownloaded, .downloading:
                return .blue
            case .checking, .checkingDirectory:
                return .secondary
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
            }
        }
    }
}
