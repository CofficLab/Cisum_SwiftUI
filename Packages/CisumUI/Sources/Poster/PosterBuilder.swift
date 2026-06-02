import SwiftUI

// MARK: - Poster Builder
/// 海报构建器，用于链式配置海报参数
public struct PosterBuilder {
    // 标题视图
    let titleView: AnyView
    var titleFontSize: CGFloat = 120

    // 副标题相关
    var subtitleTop: String?
    var subtitleTopFontSize: CGFloat = 34
    var subtitleBottom: String?
    var subtitleBottomFontSize: CGFloat = 24

    // 布局参数
    var hSpacing: CGFloat = 240
    var leftWidthRatio: CGFloat = 0.3
    var rightWidthRatio: CGFloat = 0.3
    var rightHeightRatio: CGFloat = 0.5

    // Logo 配置
    var showLogo: Bool = true
    var overlayLogoAlignment: Alignment = .topLeading
    var overlayLogoSize: CGFloat = 180

    // 右侧内容
    var rightContent: any View = EmptyView()

    // 背景视图
    var backgroundView: AnyView? = nil

    public init(titleView: AnyView) {
        self.titleView = titleView
    }
}

// MARK: - Poster Builder Chainable Methods
public extension PosterBuilder {
    /// 设置上方副标题
    /// - Parameter subtitle: 副标题文本
    /// - Returns: 配置后的 PosterBuilder
    func withPosterSubTitle(_ subtitle: String?) -> Self {
        var builder = self
        builder.subtitleTop = subtitle
        return builder
    }

    /// 设置下方副标题
    /// - Parameter subtitle: 副标题文本
    /// - Returns: 配置后的 PosterBuilder
    func withPosterBottomSubTitle(_ subtitle: String?) -> Self {
        var builder = self
        builder.subtitleBottom = subtitle
        return builder
    }

    /// 设置标题字体大小
    /// - Parameter size: 字体大小
    /// - Returns: 配置后的 PosterBuilder
    func withPosterTitleFontSize(_ size: CGFloat) -> Self {
        var builder = self
        builder.titleFontSize = size
        return builder
    }

    /// 设置上方副标题字体大小
    /// - Parameter size: 字体大小
    /// - Returns: 配置后的 PosterBuilder
    func withPosterSubTitleFontSize(_ size: CGFloat) -> Self {
        var builder = self
        builder.subtitleTopFontSize = size
        return builder
    }

    /// 设置下方副标题字体大小
    /// - Parameter size: 字体大小
    /// - Returns: 配置后的 PosterBuilder
    func withPosterBottomSubTitleFontSize(_ size: CGFloat) -> Self {
        var builder = self
        builder.subtitleBottomFontSize = size
        return builder
    }

    /// 设置右侧内容
    /// - Parameter content: 右侧视图内容
    /// - Returns: 配置后的 PosterBuilder
    func withPosterRightContent<Content: View>(_ content: Content) -> Self {
        var builder = self
        builder.rightContent = content
        return builder
    }

    /// 设置预览视图
    /// - Parameter content: 预览视图内容
    /// - Returns: 配置后的 PosterBuilder
    func withPosterPreview<Content: View>(_ content: Content) -> Self {
        var builder = self
        builder.rightContent = content
        return builder
    }

    /// 设置布局间距
    /// - Parameter spacing: 水平间距
    /// - Returns: 配置后的 PosterBuilder
    func withPosterSpacing(_ spacing: CGFloat) -> Self {
        var builder = self
        builder.hSpacing = spacing
        return builder
    }

    /// 设置左侧宽度比例
    /// - Parameter ratio: 宽度比例 (0-1)
    /// - Returns: 配置后的 PosterBuilder
    func withPosterLeftWidthRatio(_ ratio: CGFloat) -> Self {
        var builder = self
        builder.leftWidthRatio = ratio
        return builder
    }

    /// 设置右侧宽度比例
    /// - Parameter ratio: 宽度比例 (0-1)
    /// - Returns: 配置后的 PosterBuilder
    func withPosterRightWidthRatio(_ ratio: CGFloat) -> Self {
        var builder = self
        builder.rightWidthRatio = ratio
        return builder
    }

    /// 设置右侧高度比例
    /// - Parameter ratio: 高度比例 (0-1)
    /// - Returns: 配置后的 PosterBuilder
    func withPosterRightHeightRatio(_ ratio: CGFloat) -> Self {
        var builder = self
        builder.rightHeightRatio = ratio
        return builder
    }

    /// 设置 Logo 对齐方式
    /// - Parameter alignment: 对齐方式
    /// - Returns: 配置后的 PosterBuilder
    func withPosterLogoAlignment(_ alignment: Alignment) -> Self {
        var builder = self
        builder.overlayLogoAlignment = alignment
        return builder
    }

    /// 设置 Logo 大小
    /// - Parameter size: Logo 大小
    /// - Returns: 配置后的 PosterBuilder
    func withPosterLogoSize(_ size: CGFloat) -> Self {
        var builder = self
        builder.overlayLogoSize = size
        return builder
    }

    /// 设置背景颜色
    /// - Parameter color: 背景颜色
    /// - Returns: 配置后的 PosterBuilder
    func withPosterBackground(_ color: Color) -> Self {
        var builder = self
        builder.backgroundView = AnyView(color)
        return builder
    }

    /// 设置背景渐变
    /// - Parameters:
    ///   - colors: 渐变颜色数组
    ///   - startPoint: 渐变起始点
    ///   - endPoint: 渐变结束点
    /// - Returns: 配置后的 PosterBuilder
    func withPosterBackground(
        gradient colors: [Color],
        startPoint: UnitPoint = .topLeading,
        endPoint: UnitPoint = .bottomTrailing
    ) -> Self {
        var builder = self
        builder.backgroundView = AnyView(
            LinearGradient(
                colors: colors,
                startPoint: startPoint,
                endPoint: endPoint
            )
        )
        return builder
    }

    /// 设置背景材质
    /// - Parameter material: 材质类型
    /// - Returns: 配置后的 PosterBuilder
    func withPosterBackground(_ material: Material) -> Self {
        var builder = self
        builder.backgroundView = AnyView(Color.clear.background(material))
        return builder
    }

    /// 设置自定义背景视图
    /// - Parameter content: 背景视图
    /// - Returns: 配置后的 PosterBuilder
    func withPosterBackground<Content: View>(_ content: Content) -> Self {
        var builder = self
        builder.backgroundView = AnyView(content)
        return builder
    }

    /// 设置是否显示 Logo
    /// - Parameter show: 是否显示 Logo
    /// - Returns: 配置后的 PosterBuilder
    func withPosterLogo(_ show: Bool) -> Self {
        var builder = self
        builder.showLogo = show
        return builder
    }

    /// 生成海报视图
    /// - Returns: 配置好的 PosterContainer 视图
    func asPoster() -> some View {
        if let backgroundView {
            return AnyView(
                PosterContainer(
                    titleFontSize: titleFontSize,
                    subtitleTop: subtitleTop,
                    subtitleTopFontSize: subtitleTopFontSize,
                    subtitleBottom: subtitleBottom,
                    subtitleBottomFontSize: subtitleBottomFontSize,
                    hSpacing: hSpacing,
                    leftWidthRatio: leftWidthRatio,
                    rightWidthRatio: rightWidthRatio,
                    rightHeightRatio: rightHeightRatio,
                    showLogo: showLogo,
                    overlayLogoAlignment: overlayLogoAlignment,
                    overlayLogoSize: overlayLogoSize,
                    background: { backgroundView },
                    titleView: { titleView },
                    rightContent: { AnyView(rightContent) }
                )
            )
        } else {
            return AnyView(
                PosterContainer(
                    titleFontSize: titleFontSize,
                    subtitleTop: subtitleTop,
                    subtitleTopFontSize: subtitleTopFontSize,
                    subtitleBottom: subtitleBottom,
                    subtitleBottomFontSize: subtitleBottomFontSize,
                    hSpacing: hSpacing,
                    leftWidthRatio: leftWidthRatio,
                    rightWidthRatio: rightWidthRatio,
                    rightHeightRatio: rightHeightRatio,
                    showLogo: showLogo,
                    overlayLogoAlignment: overlayLogoAlignment,
                    overlayLogoSize: overlayLogoSize,
                    titleView: { titleView },
                    rightContent: { AnyView(rightContent) }
                )
            )
        }
    }
}
