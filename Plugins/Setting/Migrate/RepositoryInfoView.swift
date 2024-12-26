import MagicKit
import SwiftUI

struct RepositoryInfoView: View {
    let title: String
    let location: StorageLocation
    let url: URL?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 标题部分
            headerView
            
            // 仓库地址部分
            repositoryPathView
            
            // 文件列表
            if let url = url {
                FileItemView(
                    file: url.lastPathComponent,
                    fileStatus: nil,
                    rootURL: url.deletingLastPathComponent()
                )
                .padding(.horizontal)
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
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.accentColor.opacity(0.1))
        .cornerRadius(6)
    }
}
