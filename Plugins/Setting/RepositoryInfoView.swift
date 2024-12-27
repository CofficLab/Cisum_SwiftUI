import MagicKit
import MagicUI
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
                if let rootURL = url {
                    FileItemView(
                        file: file,
                        fileStatus: processedFiles.first(where: { $0.name == file }),
                        rootURL: rootURL
                    )
                    .transition(.opacity)
                }
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
