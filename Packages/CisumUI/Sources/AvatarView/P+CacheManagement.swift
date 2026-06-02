#if DEBUG
import SwiftUI

/// 头像视图缓存管理预览
public struct AvatarCacheManagementPreview: View {
    @State private var cacheFiles: [URL] = []

    public init() {
        _cacheFiles = State(initialValue: AvatarPreviewHelpers.loadCacheFiles())
    }

    public var body: some View {
        HStack {
            VStack(spacing: 32) {
                VDemoSection(title: "缓存文件夹", icon: "folder") {
                    VStack(spacing: 16) {
                        // 显示缓存目录路径和打开按钮
                        HStack {
                            Text(URL.thumbnailCacheDirectory().path)
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            URL.thumbnailCacheDirectory()
                                .makeOpenButton()
                        }

                        if cacheFiles.isEmpty {
                            Text("缓存文件夹为空")
                                .foregroundStyle(.secondary)
                        } else {
                            // 显示缓存文件列表
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 20) {
                                    ForEach(cacheFiles, id: \.lastPathComponent) { url in
                                        VStack {
                                            Text(url.lastPathComponent)
                                                .font(.caption)
                                                .lineLimit(1)
                                                .frame(width: 100)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }

                            // 清理缓存按钮
                            Button("清理缓存") {
                                ThumbnailCache.shared.clearCache()
                                cacheFiles = AvatarPreviewHelpers.loadCacheFiles()
                            }
                            .buttonStyle(.borderless)
                            .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .padding()
            .frame(maxWidth: 500)
        }
        .infinite()
    }
}

// MARK: - Preview

#if DEBUG
#Preview("缓存管理") {
    AvatarCacheManagementPreview()
        .frame(width: 500, height: 300)
}
#endif
#endif
