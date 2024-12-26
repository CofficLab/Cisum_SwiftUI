import SwiftUI
import MagicKit

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
            // 当前项行
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
                
                FileIconView(
                    url: viewModel.url,
                    isDirectory: viewModel.isDirectory,
                    downloadStatus: viewModel.downloadStatus,
                    fileStatus: fileStatus
                )
                
                Text(file)
                    .font(.caption)
                    .foregroundColor(
                        fileStatus?.status == .processing ? .primary : .secondary
                    )
                
                Spacer()
                
                FileInfoView(
                    itemSize: viewModel.itemSize,
                    downloadStatus: viewModel.downloadStatus,
                    isProcessing: fileStatus?.status == .processing
                )
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
}

extension Notification.Name {
    static let fileStatusUpdated = Notification.Name("fileStatusUpdated")
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
