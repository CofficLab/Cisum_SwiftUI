import SwiftUI
import MagicKit

struct FileItemView: View {
    let url: URL
    let level: Int
    let isExpanded: Bool
    let showDownloadStatus: Bool
    
    @StateObject private var viewModel: FileItemViewModel
    @State private var isHovered = false
    
    init(
        url: URL,
        level: Int = 0,
        isExpanded: Bool = false,
        showDownloadStatus: Bool = false
    ) {
        self.url = url
        self.level = level
        self.isExpanded = isExpanded
        self.showDownloadStatus = showDownloadStatus
        _viewModel = StateObject(wrappedValue: FileItemViewModel(
            url: url,
            isExpanded: isExpanded,
            shouldCheckStatus: showDownloadStatus
        ))
    }
    
    private var backgroundStyle: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(
                viewModel.isProcessing ? Color.accentColor.opacity(0.1) :
                    isHovered ? Color.secondary.opacity(0.05) :
                        Color.clear
            )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 当前项目行
            HStack(spacing: 4) {
                // 缩进和展开按钮
                HStack(spacing: 0) {
                    ForEach(0..<level, id: \.self) { _ in
                        Rectangle()
                            .fill(Color.secondary.opacity(0.1))
                            .frame(width: 1)
                            .padding(.horizontal, 8)
                    }
                }
                
                // 展开/折叠按钮
                if viewModel.isDirectory {
                    Button {
                        withAnimation {
                            viewModel.isExpanded.toggle()
                        }
                    } label: {
                        Image(systemName: viewModel.isExpanded ? "chevron.down" : "chevron.right")
                            .foregroundColor(.secondary)
                            .frame(width: 16)
                    }
                    .buttonStyle(.plain)
                } else {
                    Spacer()
                        .frame(width: 16)
                }
                
                // 文件图标
                FileIconView(
                    url: viewModel.url,
                    isDirectory: viewModel.isDirectory,
                    downloadStatus: viewModel.downloadStatus,
                    isProcessing: viewModel.isProcessing
                )
                .frame(width: 20)
                
                // 文件名
                Text(url.lastPathComponent)
                    .font(.system(size: 13))
                    .foregroundColor(viewModel.isProcessing ? .primary : .secondary)
                
                Spacer()
                
                // 文件信息
                FileInfoView(
                    itemSize: viewModel.itemSize,
                    downloadStatus: viewModel.downloadStatus,
                    isProcessing: viewModel.isProcessing,
                    showDownloadStatus: showDownloadStatus
                )
            }
            .padding(.vertical, 2)
            .padding(.horizontal, 4)
            .background(backgroundStyle)
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.15)) {
                    isHovered = hovering
                }
            }
            .contextMenu {
                Button(action: showInFinder) {
                    Label("在 Finder 中显示", systemImage: "folder")
                }
                
                Button(action: copyPath) {
                    Label("复制路径", systemImage: "doc.on.doc")
                }
            }
            
            // 子项目
            if viewModel.isExpanded {
                ForEach(viewModel.subItems, id: \.path) { subURL in
                    FileItemView(
                        url: subURL,
                        level: level + 1,
                        showDownloadStatus: showDownloadStatus
                    )
                    .transition(.opacity)
                }
            }
        }
        .task {
            if showDownloadStatus {
                await viewModel.checkStatus()
            }
        }
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

#Preview("单个文件") {
    FileItemView(
        url: URL(filePath: "/Users/user/Music/test.mp3"),
        showDownloadStatus: true
    )
    .padding()
}

#Preview("目录结构") {
    FileItemView(
        url: URL(filePath: "/Users/user/Music/专辑"),
        isExpanded: true,
        showDownloadStatus: true
    )
    .padding()
}

#Preview("不同状态") {
    VStack(alignment: .leading, spacing: 8) {
        // 普通文件
        FileItemView(
            url: URL(filePath: "/Users/user/Music/普通文件.mp3"),
            showDownloadStatus: true
        )
        
        // 正在下载的文件
        FileItemView(
            url: URL(filePath: "/Users/user/Music/下载中.mp3"),
            showDownloadStatus: true
        )
        
        // 未下载的文件
        FileItemView(
            url: URL(filePath: "/Users/user/Music/云端文件.mp3"),
            showDownloadStatus: true
        )
        
        // 不同类型的文件
        FileItemView(
            url: URL(filePath: "/Users/user/Music/音频.mp3"),
            showDownloadStatus: true
        )
        FileItemView(
            url: URL(filePath: "/Users/user/Music/视频.mp4"),
            showDownloadStatus: true
        )
        FileItemView(
            url: URL(filePath: "/Users/user/Music/图片.jpg"),
            showDownloadStatus: true
        )
        FileItemView(
            url: URL(filePath: "/Users/user/Music/文档.pdf"),
            showDownloadStatus: true
        )
    }
    .padding()
}

#Preview("列表样式") {
    VStack(spacing: 0) {
        TableHeaderView()
        
        VStack(alignment: .leading, spacing: 0) {
            FileItemView(
                url: URL(filePath: "/Users/user/Music/专辑"),
                isExpanded: true,
                showDownloadStatus: true
            )
            
            FileItemView(
                url: URL(filePath: "/Users/user/Music/单曲.mp3"),
                showDownloadStatus: true
            )
            
            FileItemView(
                url: URL(filePath: "/Users/user/Music/播放列表.m3u"),
                showDownloadStatus: true
            )
        }
        .padding(.horizontal)
    }
    .background(Color.secondary.opacity(0.02))
    .cornerRadius(6)
    .padding()
}

#Preview("不显示下载状态") {
    FileItemView(
        url: URL(filePath: "/Users/user/Music/test.mp3"),
        showDownloadStatus: false
    )
    .padding()
}
