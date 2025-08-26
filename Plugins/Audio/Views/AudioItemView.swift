import MagicCore
import SwiftUI

/// 音频列表项视图组件
/// 用于在 AudioList 中展示单个音频文件
struct AudioItemView: View {
    let url: URL
    @EnvironmentObject var audioManager: AudioProvider
    
    // 使用 equatable 来避免不必要的重绘
    private var downloadProgress: Binding<Double> {
        Binding(
            get: { audioManager.downloadProgress[url.path] ?? 1.1 },
            set: { _ in }
        )
    }

    init(_ url: URL) {
        self.url = url
    }
    
    var body: some View {
        url.makeMediaView()
            .magicAvatarDownloadProgress(downloadProgress)
            .magicPadding(horizontal: 0, vertical: 0)
            .magicVerbose(false)
            .showAvatar(true)
            .magicShowLogButtonInDebug()
            .magicHideActions()
            .tag(url as URL?)
    }
}

#Preview("App - Large") {
    AppPreview()
        .frame(width: 600, height: 1000)
}

#Preview("App - Small") {
    AppPreview()
        .frame(width: 600, height: 600)
}

#if os(iOS)
#Preview("iPhone") {
    AppPreview()
}
#endif
