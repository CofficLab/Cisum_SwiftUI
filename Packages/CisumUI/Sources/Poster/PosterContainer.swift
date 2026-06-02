import SwiftUI

/// 通用的 App Store 展示容器：左侧标题文案 + 右侧预览内容 + 整体右上角 Logo
struct PosterContainer<Title: View, RightContent: View, Background: View>: View {
    // 左侧主标题视图
    let titleView: Title
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
    let showLogo: Bool
    let overlayLogoAlignment: Alignment
    let overlayLogoSize: CGFloat

    // 背景视图
    let background: Background

    public init(
        titleFontSize: CGFloat = 120,
        subtitleTop: String? = nil,
        subtitleTopFontSize: CGFloat = 34,
        subtitleBottom: String? = nil,
        subtitleBottomFontSize: CGFloat = 24,
        hSpacing: CGFloat = 240,
        leftWidthRatio: CGFloat = 0.3,
        rightWidthRatio: CGFloat = 0.3,
        rightHeightRatio: CGFloat = 0.5,
        showLogo: Bool = true,
        overlayLogoAlignment: Alignment = .topLeading,
        overlayLogoSize: CGFloat = 180,
        @ViewBuilder background: () -> Background = {
            #if os(iOS)
            Color(uiColor: .systemBackground)
            #elseif os(macOS)
            Color(nsColor: .windowBackgroundColor)
            #elseif os(watchOS)
            Color.black
            #else
            Color.white
            #endif
        },
        @ViewBuilder titleView: () -> Title,
        @ViewBuilder rightContent: () -> RightContent
    ) {
        self.titleFontSize = titleFontSize
        self.subtitleTop = subtitleTop
        self.subtitleTopFontSize = subtitleTopFontSize
        self.subtitleBottom = subtitleBottom
        self.subtitleBottomFontSize = subtitleBottomFontSize
        self.hSpacing = hSpacing
        self.leftWidthRatio = leftWidthRatio
        self.rightWidthRatio = rightWidthRatio
        self.rightHeightRatio = rightHeightRatio
        self.showLogo = showLogo
        self.overlayLogoAlignment = overlayLogoAlignment
        self.overlayLogoSize = overlayLogoSize
        self.background = background()
        self.titleView = titleView()
        self.rightContent = rightContent()
    }

    public var body: some View {
        GeometryReader { geo in
            HStack(spacing: hSpacing) {
                Spacer()

                // 左侧：文案
                VStack(alignment: .leading, spacing: 40) {
                    Spacer()

                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 48) {
                            titleView
                                .font(.system(size: titleFontSize, weight: .bold, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.blue, Color.purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )

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
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                    .frame(height: geo.size.height * rightHeightRatio)
                    .frame(width: geo.size.width * rightWidthRatio)

                Spacer()
            }
            .background(background)
        }
        .overlay(alignment: overlayLogoAlignment) {
            if showLogo {
                Image.house
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: overlayLogoSize, height: overlayLogoSize)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 36, style: .continuous))
                    .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
                    .padding(20)
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview("App Store Hero - Basic") {
    PosterContainer(
        subtitleTop: "Build something amazing",
        subtitleBottom: "Available on the App Store",
        titleView: {
            Text("My App")
        },
        rightContent: {
            VStack {
                Image(systemName: "star.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.yellow)
                Text("Preview Content")
                    .font(.title)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    )
    .frame(height: 500)
}

#if DEBUG
#Preview("App Store Hero - Custom") {
    PosterContainer(
        titleFontSize: 100,
        subtitleTop: "释放你的创造力",
        subtitleTopFontSize: 30,
        subtitleBottom: "Version 1.0 - Now Available",
        hSpacing: 200,
        background: {
            LinearGradient(
                colors: [Color.mint.opacity(0.3), Color.cyan.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        },
        titleView: {
            Text("创意工具")
        },
        rightContent: {
            VStack(spacing: 20) {
                Image(systemName: "paintbrush.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue.gradient)
                Text("Design Tools")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("Create stunning designs with ease")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(40)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    )
    .frame(height: 600)
}
#endif
#endif
