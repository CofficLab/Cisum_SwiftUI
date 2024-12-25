import MagicKit
import SwiftUI

struct RepositoryInfoView: View {
    let title: String
    let location: StorageLocation
    let url: URL?
    let files: [String]
    let processedFiles: [FileStatus]

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
            Text(title == "源仓库" ? "包含以下文件：" : "已有以下文件：")
                .font(.caption)
                .foregroundColor(.secondary)

            ForEach(filteredFiles, id: \.self) { file in
                FileItemView(
                    file: file,
                    fileStatus: processedFiles.first(where: { $0.name == file }),
                    isSourceRepository: title == "源仓库"
                )
            }
        }
        .frame(maxWidth: .infinity)
        .frame(alignment: .leading)
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.accentColor.opacity(0.1))
        .cornerRadius(6)
    }
}

// 将文件项提取为单独的视图
struct FileItemView: View {
    let file: String
    let fileStatus: FileStatus?
    let isSourceRepository: Bool
    
    var body: some View {
        HStack {
            if isSourceRepository {
                statusIcon
                fileName
                Spacer()
                // 添加状态描述
                if let status = fileStatus?.downloadStatus {
                    Text(status.description)
                        .font(.caption)
                        .foregroundColor(status.color)
                }
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text(file)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 2)
        .background(
            fileStatus?.status == .processing ? 
                Color.accentColor.opacity(0.1) : 
                Color.clear
        )
        .cornerRadius(4)
    }
    
    private var statusIcon: some View {
        Group {
            if let fileStatus = fileStatus {
                if case .processing = fileStatus.status {
                    Image(systemName: fileStatus.status.icon)
                        .foregroundColor(fileStatus.status.color)
                        .rotationEffect(.degrees(360))
                        .animation(
                            .linear(duration: 1.0)
                            .repeatForever(autoreverses: false),
                            value: fileStatus.status
                        )
                } else {
                    Image(systemName: fileStatus.status.icon)
                        .foregroundColor(fileStatus.status.color)
                }
            } else {
                Image(systemName: "circle")
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var fileName: some View {
        Text(file)
            .font(.caption)
            .foregroundColor(
                fileStatus?.status == .processing ? .primary : .secondary
            )
    }
}
