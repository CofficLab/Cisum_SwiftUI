import PluginRegistry
import SwiftUI

struct AppStoreMinimal: View {
    var body: some View {
        GeometryReader { geo in
            HStack {
                Group {
                    Text("极简设计")
                        .asPosterTitle()

                    VStack(spacing: 16) {
                        AppStoreFeatureItem(
                            icon: "trash",
                            title: "没有广告",
                            description: "纯净体验，专注音乐"
                        )
                        AppStoreFeatureItem(
                            icon: "phone.bubble",
                            title: "没有注册",
                            description: "打开即用，快速上手"
                        )
                        AppStoreFeatureItem(
                            icon: "xmark.circle",
                            title: "没有登录",
                            description: "保护隐私，无需账号"
                        )
                        AppStoreFeatureItem(
                            icon: .cisumIconInfo,
                            title: "没有弹窗",
                            description: "简洁界面，无干扰"
                        )
                    }
                    .frame(width: geo.size.width * 0.4)
                    .cisumPy4()
                }
                .frame(width: geo.size.width * 0.5)
                .cisumVStackCenter()

                ContentLayout()
                    .hideDetail()
                    .inRootView()
                    .inDemoMode()
                    .cisumRoundedLarge()
                    .cisumShadowSm()
                    .frame(width: max(Config.minWidth, geo.size.width * 0.15))
                    .frame(height: geo.size.height * 0.4)
                    .frame(width: geo.size.width * 0.5)
                    .scaleEffect(2)
            }
        }
        .inPosterContainer()
    }
}

// MARK: - Preview

#Preview("App Store Minimal") {
    AppStoreMinimal()
        .cisumPreviewContainer(.cisumMacBook13, scale: 0.5)
}
