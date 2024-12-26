import SwiftUI

struct FileIconView: View {
    let downloadStatus: FileStatus.DownloadStatus?
    let fileStatus: FileStatus?
    
    var body: some View {
        Group {
            if let status = downloadStatus {
                Image(systemName: fileStatus?.icon ?? "circle")
                    .foregroundColor(status.color)
                    .if(fileStatus?.status == .processing) { view in
                        view.rotationEffect(.degrees(360))
                            .animation(
                                .linear(duration: 1.0)
                                .repeatForever(autoreverses: false),
                                value: fileStatus?.status
                            )
                    }
            } else {
                Image(systemName: "circle")
                    .foregroundColor(.secondary)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: downloadStatus)
    }
} 