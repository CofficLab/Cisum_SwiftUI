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

            // 文件列表
            let filteredFiles = files.filter { $0 != ".DS_Store" }
            if !filteredFiles.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title == "源仓库" ? "包含以下文件：" : "已有以下文件：")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    ForEach(filteredFiles, id: \.self) { file in
                        HStack {
                            if title == "源仓库" {
                                if let fileStatus = processedFiles.first(where: { $0.name == file }) {
                                    Image(systemName: fileStatus.status.icon)
                                        .foregroundColor(fileStatus.status.color)
                                } else {
                                    Image(systemName: "circle")
                                        .foregroundColor(.secondary)
                                }

                                Text(file)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text(file)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
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
    }
}
