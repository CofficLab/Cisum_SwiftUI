#if DEBUG
    import SwiftUI

    /// 头像视图的功能展示组件 - 主入口
    /// 整合所有拆分的预览视图
    public struct AvatarDemoView: View {
        public init() {}

        public var body: some View {
            TabView {
                // 基础样式
                AvatarBasicPreview()
                    .tabItem {
                        Label("基础", systemImage: .iconPaintpalette)
                    }

                // 文件类型
                AvatarFileTypesPreview()
                    .tabItem {
                        Label("文件类型", systemImage: .iconDocument)
                    }

                // 下载状态
                AvatarDownloadStatusPreview()
                    .tabItem {
                        Label("下载状态", systemImage: .iconDownload)
                    }

                // 错误状态
                AvatarErrorStatesPreview()
                    .tabItem {
                        Label("错误状态", systemImage: .iconWarning)
                    }

                // 缓存管理
                AvatarCacheManagementPreview()
                    .tabItem {
                        Label("缓存管理", systemImage: .iconFolder)
                    }
            }
        }
    }

// MARK: - Preview

#if DEBUG
#Preview("头像视图") {
    AvatarDemoView()
        .frame(width: 500, height: 700)
}
#endif

#endif
