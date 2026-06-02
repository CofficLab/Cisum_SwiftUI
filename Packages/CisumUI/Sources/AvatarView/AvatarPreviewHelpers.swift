#if DEBUG
import SwiftUI

/// 头像预览视图共享的工具方法和常量
public enum AvatarPreviewHelpers {
    /// 演示区域的统一布局
    static func demoSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.headline)
            content()
        }
    }

    /// 加载缓存文件的静态方法
    static func loadCacheFiles() -> [URL] {
        let cacheDir = URL.thumbnailCacheDirectory()
        guard let files = try? FileManager.default.contentsOfDirectory(
            at: cacheDir,
            includingPropertiesForKeys: nil
        ) else {
            return []
        }
        return files
    }
}
#endif
