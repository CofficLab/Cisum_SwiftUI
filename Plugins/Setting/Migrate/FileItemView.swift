import SwiftUI
import MagicKit

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

@MainActor
class FileItemViewModel: ObservableObject {
    @Published private(set) var downloadStatus: FileStatus.DownloadStatus?
    @Published private(set) var subItems: [URL] = []
    @Published var isExpanded = false
    @Published private(set) var itemSize: Int64 = 0
    
    private let statusChecker = DirectoryStatusChecker()
    private let url: URL
    private let isDirectory: Bool
    
    init(url: URL) {
        self.url = url
        
        // 检查是否为目录
        var isDir: ObjCBool = false
        FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir)
        self.isDirectory = isDir.boolValue
        
        if isDirectory {
            // 如果是目录，预先加载子项目
            loadSubItems()
        }
        
        // 异步计算大小
        Task {
            await calculateSize()
        }
    }
    
    private func calculateSize() async {
        let size = await Task.detached(priority: .background) {
            if self.isDirectory {
                return await self.calculateFolderSize(url: self.url)
            } else {
                return Int64((try? self.url.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0)
            }
        }.value
        
        await MainActor.run {
            self.itemSize = size
        }
    }
    
    private func calculateFolderSize(url: URL) -> Int64 {
        let fileManager = FileManager.default
        guard let enumerator = fileManager.enumerator(
            at: url,
            includingPropertiesForKeys: [.totalFileAllocatedSizeKey, .fileAllocatedSizeKey],
            options: [],
            errorHandler: nil
        ) else { return 0 }
        
        var totalSize: Int64 = 0
        for case let fileURL as URL in enumerator {
            guard let resourceValues = try? fileURL.resourceValues(forKeys: [.totalFileAllocatedSizeKey, .fileAllocatedSizeKey]),
                  let size = resourceValues.totalFileAllocatedSize ?? resourceValues.fileAllocatedSize
            else { continue }
            totalSize += Int64(size)
        }
        return totalSize
    }
    
    private func loadSubItems() {
        guard isDirectory else { return }
        
        do {
            subItems = try FileManager.default.contentsOfDirectory(
                at: url,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: [.skipsHiddenFiles]
            ).filter { $0.lastPathComponent != ".DS_Store" }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
        } catch {
            print("Error loading subitems: \(error)")
        }
    }
    
    func checkStatus() async {
        downloadStatus = await statusChecker.checkItemStatus(url) { _, status in
            Task { @MainActor in
                withAnimation {
                    self.downloadStatus = status
                    NotificationCenter.default.post(
                        name: .fileStatusUpdated,
                        object: (self.url.lastPathComponent, status)
                    )
                }
            }
        }
    }
}

struct FileItemView: View {
    let file: String
    let fileStatus: FileStatus?
    let rootURL: URL
    let level: Int
    
    @StateObject private var viewModel: FileItemViewModel
    
    init(
        file: String,
        fileStatus: FileStatus?,
        rootURL: URL,
        level: Int = 0
    ) {
        self.file = file
        self.fileStatus = fileStatus
        self.rootURL = rootURL
        self.level = level
        let fileURL = rootURL.appendingPathComponent(file)
        _viewModel = StateObject(wrappedValue: FileItemViewModel(url: fileURL))
    }
    
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
        VStack(alignment: .leading, spacing: 2) {
            // 当前项目行
            HStack {
                // 缩进
                HStack(spacing: 0) {
                    ForEach(0..<level, id: \.self) { _ in
                        Rectangle()
                            .fill(Color.secondary.opacity(0.2))
                            .frame(width: 1)
                            .padding(.horizontal, 8)
                    }
                }
                
                // 展开/折叠按钮（仅对目录显示）
                if !viewModel.subItems.isEmpty {
                    Button {
                        withAnimation {
                            viewModel.isExpanded.toggle()
                        }
                    } label: {
                        Image(systemName: viewModel.isExpanded ? "chevron.down" : "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                } else {
                    Text("")
                        .frame(width: 20)
                }
                
                // 状态图标
                statusIcon
                
                // 文件名
                fileName
                
                Spacer()
                
                // 文件大小
                Text(formatFileSize(viewModel.itemSize))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(minWidth: 60, alignment: .trailing)
                
                // 状态描述
                if let status = viewModel.downloadStatus {
                    Text(status.description)
                        .font(.caption)
                        .foregroundColor(status.color)
                        .transition(.opacity)
                        .frame(minWidth: 80, alignment: .trailing)
                }
            }
            .padding(.vertical, 2)
            .background(
                fileStatus?.status == .processing ? 
                Color.accentColor.opacity(0.1) : 
                Color.clear
            )
            .cornerRadius(4)
            
            // 子项目（如果展开）
            if viewModel.isExpanded {
                ForEach(viewModel.subItems, id: \.path) { subURL in
                    FileItemView(
                        file: subURL.lastPathComponent,
                        fileStatus: nil,
                        rootURL: subURL.deletingLastPathComponent(),
                        level: level + 1
                    )
                    .transition(.opacity)
                }
            }
        }
        .task {
            await viewModel.checkStatus()
        }
    }
    
    private var statusIcon: some View {
        Group {
            if let status = viewModel.downloadStatus {
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
            } else {
                Image(systemName: "circle")
                    .foregroundColor(.secondary)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.downloadStatus)
    }
    
    private var fileName: some View {
        Text(file)
            .font(.caption)
            .foregroundColor(
                fileStatus?.status == .processing ? .primary : .secondary
            )
    }
}

extension Notification.Name {
    static let fileStatusUpdated = Notification.Name("fileStatusUpdated")
}
