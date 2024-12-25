import Foundation
import SwiftUI

struct FileItemView: View {
    let file: String
    let fileStatus: FileStatus?
    let downloadStatus: FileStatus.DownloadStatus?

    var body: some View {
        HStack { statusIcon
            fileName
            Spacer()
            // 添加状态描述
            if let status = downloadStatus {
                Text(status.description)
                    .font(.caption)
                    .foregroundColor(status.color)
                    .transition(.opacity)
            } else if fileStatus?.status == .processing {
                Text("检查中...")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .transition(.opacity)
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
            if let status = downloadStatus {
                Image(systemName: status.icon)
                    .foregroundColor(status.color)
                    .if(fileStatus?.status == .processing) { view in
                        view.rotationEffect(.degrees(360))
                            .animation(
                                .linear(duration: 1.0)
                                    .repeatForever(autoreverses: false),
                                value: fileStatus?.status
                            )
                    }
            } else if let fileStatus = fileStatus {
                Image(systemName: fileStatus.status.icon)
                    .foregroundColor(fileStatus.status.color)
                    .if(fileStatus.status == .processing) { view in
                        view.rotationEffect(.degrees(360))
                            .animation(
                                .linear(duration: 1.0)
                                    .repeatForever(autoreverses: false),
                                value: fileStatus.status
                            )
                    }
            } else {
                Image(systemName: "circle")
                    .foregroundColor(.secondary)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: downloadStatus)
    }

    private var fileName: some View {
        Text(file)
            .font(.caption)
            .foregroundColor(
                fileStatus?.status == .processing ? .primary : .secondary
            )
    }
}
