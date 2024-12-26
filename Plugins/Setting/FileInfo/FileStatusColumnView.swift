import MagicKit
import OSLog
import SwiftUI

struct FileStatusColumnView: View, SuperLog {
    static let emoji: String = "🥩"

    let url: URL
    @State private var fileStatus: String = "检查中..."
    @State private var isChecking: Bool = true
    @State private var statusColor: Color = .gray

    // 添加静态缓存
    private static var statusCache: [String: (status: String, color: Color)] = [:]

    var body: some View {
        Text(fileStatus)
            .foregroundColor(statusColor)
            .task(priority: .background) {
                checkFileStatus(verbose: true)
            }
    }

    private func checkFileStatus(verbose: Bool = false) {
        Task.detached(priority: .high) {
            // 检查缓存
            let path = url.path(percentEncoded: false)
            if let cached = Self.statusCache[path] {
                await updateState(fileStatus: cached.status, statusColor: cached.color, isChecking: false)
                if verbose {
                    os_log("\(Self.t)📦 Using cached status for \(path)")
                }
                return
            }
            
            if verbose {
                os_log("\(Self.t)🔍 Checking file status for \(path)")
            }
            
            // 获取文件状态信息
            let resourceValues = try? url.resourceValues(forKeys: [
                .ubiquitousItemDownloadingStatusKey,
                .ubiquitousItemIsDownloadingKey,
                .isDirectoryKey,
            ])

            // 根据获取的状态信息更新UI
            if let resourceValues {
                if resourceValues.isDirectory == true {
                    await checkDirectoryStatus(url)
                } else {
                    await checkSingleFileStatus(resourceValues)
                }
            } else {
                let status = "本地文件"
                let color: Color = .primary
                Self.statusCache[path] = (status, color)
                await updateState(fileStatus: status, statusColor: color, isChecking: false)
            }
        }
    }

    private func checkDirectoryStatus(_ directoryURL: URL, verbose: Bool = false) {
        Task.detached(priority: .background) {
            if verbose {
                os_log("\(Self.t)🔍 Checking directory status for \(directoryURL.path(percentEncoded: false))")
            }

            var fileStats = (downloaded: 0, notDownloaded: 0)

            if let enumerator = FileManager.default.enumerator(
                at: directoryURL,
                includingPropertiesForKeys: [.ubiquitousItemDownloadingStatusKey],
                options: [.skipsHiddenFiles]
            ) {
                for case let itemURL as URL in enumerator {
                    guard let itemValues = try? itemURL.resourceValues(forKeys: [.ubiquitousItemDownloadingStatusKey]),
                          let downloadStatus = itemValues.ubiquitousItemDownloadingStatus
                    else { continue }

                    switch downloadStatus {
                    case .current, .downloaded:
                        fileStats.downloaded += 1
                    case .notDownloaded:
                        fileStats.notDownloaded += 1
                    default:
                        break
                    }
                }
            }

            // 根据统计结果一次性更新UI状态
            let (status, color) = if fileStats.downloaded > 0 || fileStats.notDownloaded > 0 {
                ("\(fileStats.downloaded)个已下载, \(fileStats.notDownloaded)个未下载",
                 fileStats.downloaded > 0 ? Color.green : Color.orange)
            } else {
                ("本地目录", Color.primary)
            }

            // 保存结果到缓存
            let path = directoryURL.path(percentEncoded: false)
            Self.statusCache[path] = (status, color)
            
            await updateState(fileStatus: status, statusColor: color, isChecking: false)
        }
    }

    private func checkSingleFileStatus(_ resourceValues: URLResourceValues, verbose: Bool = false) {
        Task.detached(priority: .background) {
            if verbose {
                os_log("\(Self.t)🔍 Checking single file status for \(url.path(percentEncoded: false))")
            }

            let (status, color) = if let downloadStatus = resourceValues.ubiquitousItemDownloadingStatus {
                switch downloadStatus {
                case .current, .downloaded:
                    ("已下载", Color.green)
                case .notDownloaded:
                    ("未下载", Color.orange)
                default:
                    ("本地文件", Color.primary)
                }
            } else {
                ("本地文件", Color.primary)
            }

            // 保存结果到缓存
            let path = url.path(percentEncoded: false)
            Self.statusCache[path] = (status, color)
            
            await updateState(fileStatus: status, statusColor: color, isChecking: false)
        }
    }

    @MainActor
    private func updateState(fileStatus: String, statusColor: Color, isChecking: Bool) {
        Task(priority: .background) {
            self.fileStatus = fileStatus
            self.statusColor = statusColor
            self.isChecking = isChecking
        }
    }
}

#Preview {
    FileStatusColumnView(url: URL(filePath: "/Users/user/Downloads/test.txt"))
}
