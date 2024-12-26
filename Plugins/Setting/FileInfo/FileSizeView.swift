import SwiftUI

struct FileSizeView: View {
    let url: URL
    @State private var size: Int64?
    
    var body: some View {
        Group {
            if let size = size {
                Text(formatFileSize(size))
            } else {
                Text("计算中...")
                    .foregroundStyle(.secondary)
            }
        }
        .task {
            size = await calculateSize(url)
        }
    }
    
    private func formatFileSize(_ size: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
    
    private func calculateSize(_ url: URL) async -> Int64 {
        var totalSize: Int64 = 0
        
        guard let resourceValues = try? url.resourceValues(forKeys: [.isDirectoryKey]),
              let isDirectory = resourceValues.isDirectory else {
            return (try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int64) ?? 0
        }
        
        if isDirectory {
            guard let urls = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.fileSizeKey])?.allObjects as? [URL] else {
                return 0
            }
            
            for fileURL in urls {
                if let fileSize = try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                    totalSize += Int64(fileSize)
                }
            }
            return totalSize
        } else {
            return (try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int64) ?? 0
        }
    }
}

#Preview {
    FileSizeView(url: URL(filePath: "/Users/user/Desktop"))
} 