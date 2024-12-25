import MagicKit
import SwiftUI

struct FileStats: Equatable {
    var downloaded: Int = 0
    var downloading: Int = 0
    var notDownloaded: Int = 0
    
    var isEmpty: Bool {
        downloaded == 0 && downloading == 0 && notDownloaded == 0
    }
}

struct RepositoryInfoView: View {
    let title: String
    let location: StorageLocation
    let url: URL?
    let files: [String]
    let processedFiles: [FileStatus]
    
    @StateObject private var statusChecker = DirectoryStatusChecker()
    @State private var fileStatuses: [String: FileStatus.DownloadStatus] = [:]
    @State private var totalStats = FileStats()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 标题部分
            headerView
            
            // 仓库地址部分
            repositoryPathView
            
            // 文件列表部分
            if !filteredFiles.isEmpty {
                fileListView
            }
        }
        .task {
            // 预先初始化所有文件状态为检查中
            let initialStatuses = Dictionary(
                uniqueKeysWithValues: filteredFiles.map { ($0, FileStatus.DownloadStatus.checking) }
            )
            await MainActor.run {
                withAnimation {
                    fileStatuses = initialStatuses
                }
            }
            await checkAllFileStatuses()
        }
    }
    
    private var headerView: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            Spacer()
            
            Text(location.title)

            if let root = url {
                BtnOpenFolder(url: root).labelStyle(.iconOnly)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.accentColor.opacity(0.1))
        .cornerRadius(6)
    }
    
    private var repositoryPathView: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                HStack {
                    Text("仓库地址")
                    Spacer()
                    if let path = url?.path {
                        Text(path)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .help(path)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.accentColor.opacity(0.1))
            .cornerRadius(6)
        }
    }
    
    private var filteredFiles: [String] {
        files.filter { $0 != ".DS_Store" }
    }
    
    private var fileListView: some View {
        VStack(alignment: .leading, spacing: 4) {            
            if statusChecker.isChecking {
                Text("正在检查文件状态...")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .transition(.opacity)
            }
            
            if !totalStats.isEmpty {
                HStack(spacing: 8) {
                    if totalStats.downloaded > 0 {
                        Text("\(totalStats.downloaded) 已下载")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                    if totalStats.downloading > 0 {
                        Text("\(totalStats.downloading) 下载中")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    if totalStats.notDownloaded > 0 {
                        Text("\(totalStats.notDownloaded) 未下载")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 4)
                .transition(.opacity)
            }

            ForEach(filteredFiles, id: \.self) { file in
                FileItemView(
                    file: file,
                    fileStatus: processedFiles.first(where: { $0.name == file }),
                    downloadStatus: fileStatuses[file]
                )
                .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(alignment: .leading)
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.accentColor.opacity(0.1))
        .cornerRadius(6)
        .animation(.easeInOut(duration: 0.2), value: statusChecker.isChecking)
        .animation(.easeInOut(duration: 0.2), value: totalStats)
        .animation(.easeInOut(duration: 0.2), value: fileStatuses)
    }
    
    private func checkAllFileStatuses() async {
        guard let rootURL = url else { return }
        
        // 创建一个任务组来并发检查所有文件状态
        await withTaskGroup(of: (String, FileStatus.DownloadStatus).self) { group in
            for file in filteredFiles {
                group.addTask {
                    let fileURL = rootURL.appendingPathComponent(file)
                    let status = await statusChecker.checkItemStatus(fileURL) { _, status in
                        // 这里可以处理进度回调
                    }
                    return (file, status)
                }
            }
            
            // 收集结果并更新状态
            var stats = FileStats()
            var newStatuses: [String: FileStatus.DownloadStatus] = [:]
            
            for await (file, status) in group {
                // 使用 MainActor 更新单个文件状态
                await MainActor.run {
                    withAnimation {
                        fileStatuses[file] = status
                    }
                }
                
                newStatuses[file] = status
                
                // 更新统计信息
                switch status {
                case .downloaded, .local:
                    stats.downloaded += 1
                case .downloading:
                    stats.downloading += 1
                case .notDownloaded:
                    stats.notDownloaded += 1
                case .directoryStatus(_, let d, let ing, let nd):
                    stats.downloaded += d
                    stats.downloading += ing
                    stats.notDownloaded += nd
                default:
                    break
                }
            }
            
            // 更新总体统计
            await MainActor.run {
                withAnimation {
                    totalStats = stats
                }
            }
        }
    }
}



extension View {
    @ViewBuilder
    func `if`<Transform: View>(
        _ condition: Bool,
        transform: (Self) -> Transform
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
