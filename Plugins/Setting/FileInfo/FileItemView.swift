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
    static let ignoredFiles = [
        ".DS_Store",
        ".git",
        ".gitignore",
        "Thumbs.db",  // Windows 缩略图文件
        ".localized"  // macOS 本地化文件
    ]
    
    @Published private(set) var downloadStatus: FileStatus.DownloadStatus?
    @Published private(set) var subItems: [URL] = []
    @Published var isExpanded: Bool
    @Published private(set) var itemSize: Int64 = 0
    
    private let statusChecker = DirectoryStatusChecker()
    let url: URL
    let isDirectory: Bool
    
    init(url: URL, isExpanded: Bool = false) {
        self.url = url
        self.isExpanded = isExpanded
        
        // 检查是否为目录
        var isDir: ObjCBool = false
        FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir)
        self.isDirectory = isDir.boolValue
        
        if isDirectory {
            // 如果是目录，预先加载子项目
            loadSubItems()
        }
        
        // 异计算大小
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
            if FileItemViewModel.ignoredFiles.contains(fileURL.lastPathComponent) {
                continue
            }
            
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
                options: []
            ).filter { url in
                !FileItemViewModel.ignoredFiles.contains(url.lastPathComponent)
            }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
        } catch {
            print("Error loading subitems: \(error)")
        }
    }
    
    func checkStatus() async {
        // 如果是目录，先检查是否只包含被忽略的文件
        if isDirectory {
            let hasNonIgnoredFiles = subItems.contains { url in
                !FileItemViewModel.ignoredFiles.contains(url.lastPathComponent)
            }
            
            // 如果目录下只有被忽略的文件，则不显示任何状态
            if !hasNonIgnoredFiles {
                await MainActor.run {
                    self.downloadStatus = nil
                }
                return
            }
        }
        
        // 如果当前文件是被忽略的文件，则不检查状态
        if FileItemViewModel.ignoredFiles.contains(url.lastPathComponent) {
            await MainActor.run {
                self.downloadStatus = nil
            }
            return
        }
        
        // 继续检查其他文件的状态
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
    
    var fileIcon: String {
        if isDirectory {
            return "folder.fill"
        }
        
        switch url.pathExtension.lowercased() {
        case "mp3", "m4a", "wav", "aac":
            return "music.note"
        case "mp4", "mov", "avi", "mkv":
            return "film"
        case "jpg", "jpeg", "png", "gif":
            return "photo"
        case "pdf":
            return "doc.fill"
        case "txt", "md":
            return "doc.text.fill"
        default:
            return "doc.fill"
        }
    }
}

struct FileItemView: View {
    let file: String
    let fileStatus: FileStatus?
    let rootURL: URL
    let level: Int
    let isExpanded: Bool
    
    @StateObject private var viewModel: FileItemViewModel
    
    @State private var isHovered = false
    @State private var isMenuPresented = false
    
    init(
        file: String,
        fileStatus: FileStatus?,
        rootURL: URL,
        level: Int = 0,
        isExpanded: Bool = false
    ) {
        self.file = file
        self.fileStatus = fileStatus
        self.rootURL = rootURL
        self.level = level
        self.isExpanded = isExpanded
        let fileURL = rootURL.appendingPathComponent(file)
        _viewModel = StateObject(wrappedValue: FileItemViewModel(url: fileURL, isExpanded: isExpanded))
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
    
    private func showInFinder() {
        NSWorkspace.shared.selectFile(viewModel.url.path, inFileViewerRootedAtPath: "")
    }
    
    private func copyPath() {
        #if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(viewModel.url.path, forType: .string)
        #endif
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            // 当前项���行
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
                
                // 修改展开/折叠按钮的显示逻辑
                Group {
                    if viewModel.isDirectory {  // 首先判断是否为目录
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
                        Image(systemName: "chevron.right")
                            .foregroundColor(.clear)
                    }
                }
                .frame(width: 20)
                
                // 状态图标
                statusIcon
                
                // 文��名
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
                Group {
                    if fileStatus?.status == .processing {
                        Color.accentColor.opacity(0.1)
                    } else if isMenuPresented {
                        Color.secondary.opacity(0.15)
                    } else if isHovered {
                        Color.secondary.opacity(0.05)
                    } else {
                        Color.clear
                    }
                }
            )
            .cornerRadius(4)
            .contextMenu {
                Button(action: showInFinder) {
                    Label("在 Finder 中显示", systemImage: "folder")
                }
                
                Button(action: copyPath) {
                    Label("复制路径", systemImage: "doc.on.doc")
                }
            }
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.15)) {
                    isHovered = hovering
                }
            }
            .onChange(of: isMenuPresented) { newValue in
                withAnimation {
                    isMenuPresented = newValue
                }
            }
            
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
                switch status {
                case .local, .downloaded:
                    Image(systemName: viewModel.fileIcon)
                        .foregroundColor(.accentColor)
                case .downloading:
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
                case .notDownloaded:
                    Image(systemName: status.icon)
                        .foregroundColor(status.color)
                default:
                    Image(systemName: status.icon)
                        .foregroundColor(status.color)
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
