import SwiftUI
import MagicKit

struct FileInfoView: View {
    let itemSize: Int64
    let downloadStatus: FileStatus.DownloadStatus?
    let isProcessing: Bool
    
    private func formatFileSize(_ bytes: Int64) -> String {
        let units = ["B", "KB", "MB", "GB", "TB"]
        var size = Double(bytes)
        var unitIndex = 0
        
        while size >= 1024 && unitIndex < units.count - 1 {
            size /= 1024
            unitIndex += 1
        }
        
        return String(format: "%.1f %@", size, units[unitIndex])
    }
    
    var body: some View {
        HStack(spacing: 8) {
            // 文件大小
            Text(formatFileSize(itemSize))
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(minWidth: 60, alignment: .trailing)
            
            // 状态描述
            if let status = downloadStatus {
                Text(status.description)
                    .font(.caption)
                    .foregroundColor(status.color)
                    .frame(minWidth: 80, alignment: .trailing)
                    .transition(.opacity)
            }
        }
        .padding(.horizontal, 4)
        .background(
            isProcessing ? 
            Color.accentColor.opacity(0.1) : 
            Color.clear
        )
        .cornerRadius(4)
    }
}

#Preview {
    VStack(spacing: 16) {
        FileInfoView(
            itemSize: 1024 * 1024,
            downloadStatus: .downloading(progress: 0.5),
            isProcessing: true
        )
        
        FileInfoView(
            itemSize: 2048 * 1024 * 1024,
            downloadStatus: .downloaded,
            isProcessing: false
        )
        
        FileInfoView(
            itemSize: 3 * 1024 * 1024 * 1024,
            downloadStatus: .directoryStatus(
                total: 10,
                downloaded: 5,
                downloading: 2,
                notDownloaded: 3
            ),
            isProcessing: false
        )
    }
    .padding()
} 