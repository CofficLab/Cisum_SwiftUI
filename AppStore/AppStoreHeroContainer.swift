import MagicBackground
import MagicContainer
import MagicCore
import MagicUI
import SwiftUI

/// 通用的 App Store 展示容器：左侧标题文案 + 右侧预览内容 + 整体右上角 Logo
struct AppStoreHeroContainer<RightContent: View>: View {
    // 左侧主标题与副标题
    let title: String
    let titleFontSize: CGFloat
    let subtitleTop: String?
    let subtitleTopFontSize: CGFloat
    let subtitleBottom: String?
    let subtitleBottomFontSize: CGFloat

    // 布局与样式
    let hSpacing: CGFloat
    let leftWidthRatio: CGFloat
    let rightWidthRatio: CGFloat
    let rightHeightRatio: CGFloat

    // 右侧内容
    let rightContent: RightContent

    // 顶部 Logo
    let overlayLogoAlignment: Alignment
    let overlayLogoSize: CGFloat

    init(
        title: String,
        titleFontSize: CGFloat = 120,
        subtitleTop: String? = nil,
        subtitleTopFontSize: CGFloat = 34,
        subtitleBottom: String? = nil,
        subtitleBottomFontSize: CGFloat = 24,
        hSpacing: CGFloat = 240,
        leftWidthRatio: CGFloat = 0.3,
        rightWidthRatio: CGFloat = 0.3,
        rightHeightRatio: CGFloat = 0.5,
        overlayLogoAlignment: Alignment = .topLeading,
        overlayLogoSize: CGFloat = 180,
        @ViewBuilder rightContent: () -> RightContent
    ) {
        self.title = title
        self.titleFontSize = titleFontSize
        self.subtitleTop = subtitleTop
        self.subtitleTopFontSize = subtitleTopFontSize
        self.subtitleBottom = subtitleBottom
        self.subtitleBottomFontSize = subtitleBottomFontSize
        self.hSpacing = hSpacing
        self.leftWidthRatio = leftWidthRatio
        self.rightWidthRatio = rightWidthRatio
        self.rightHeightRatio = rightHeightRatio
        self.overlayLogoAlignment = overlayLogoAlignment
        self.overlayLogoSize = overlayLogoSize
        self.rightContent = rightContent()
    }

    var body: some View {
        GeometryReader { geo in
            HStack(spacing: hSpacing) {
                Spacer()

                // 左侧：文案
                VStack(alignment: .leading, spacing: 40) {
                    Spacer()

                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 48) {
                            Text(title)
                                .font(.system(size: titleFontSize, weight: .bold, design: .rounded))
                                .magicBluePurpleGradient()

                            if subtitleTop != nil || subtitleBottom != nil {
                                VStack(alignment: .leading, spacing: 12) {
                                    if let subtitleTop {
                                        Text(subtitleTop)
                                            .font(.system(size: subtitleTopFontSize, weight: .semibold, design: .rounded))
                                            .foregroundColor(.primary)
                                    }
                                    if let subtitleBottom {
                                        Text(subtitleBottom)
                                            .font(.system(size: subtitleBottomFontSize))
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }

                    Spacer()
                }
                .frame(width: geo.size.width * leftWidthRatio)

                // 右侧：内容
                rightContent
                    .background(.background.opacity(0.5))
                    .magicRoundedLarge()
                    .inMagicVStackCenter()
                    .inMagicHStackCenter()
                    .frame(height: geo.size.height * rightHeightRatio)
                    .frame(width: geo.size.width * rightWidthRatio)

                Spacer()
            }
            .inMagicBackgroundMint(0.9)
        }
        .overlay(alignment: overlayLogoAlignment) {
            Image("Logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: overlayLogoSize, height: overlayLogoSize)
                .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
                .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 3)
                .padding(16)
        }
    }
}

#Preview("App Store Hero") {
    AppStoreHero()
        .inMagicContainer(.macBook13, scale: 0.4)
}

#Preview("App Store Hero - One Tap Block") {
    AppStoreHeroBlock()
        .inMagicContainer(.macBook13, scale: 0.4)
}

#Preview("App Store Hero - Menu Bar") {
    AppStoreHeroMenuBar()
        .inMagicContainer(.macBook13, scale: 0.4)
}
