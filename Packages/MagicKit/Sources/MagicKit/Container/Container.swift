import Foundation
import MagicAlert
import SwiftUI
#if os(macOS)
    import AppKit
#endif

/// 视图容器，提供多种实用功能
struct MagicContainer<Content: View>: View {
    // MARK: - Properties

    let content: Content
    @State var containerSize: CGSize
    @State var scale: CGFloat
    let toolBarHeight: CGFloat = 100
    let tipsBarHeight: CGFloat = 60

    @Environment(\.colorScheme) private var systemColorScheme
    @State var isDarkMode: Bool = false

    var containerWidth: CGFloat { containerSize.width }
    var containerHeight: CGFloat { containerSize.height }

    // MARK: - Initialization

    /// 创建容器
    /// - Parameters:
    ///   - containerSize: 容器尺寸，默认为 500x750
    ///   - scale: 缩放比例，默认为 1.0
    ///   - content: 要预览的内容视图
    public init(
        _ containerSize: CGSize = CGSize(width: 500, height: 750),
        scale: CGFloat = 1.0,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        _containerSize = State(initialValue: containerSize)
        _scale = State(initialValue: scale)
    }

    public var body: some View {
        VStack(spacing: 0) {
            self.topToolBar

            content.frame(width: containerWidth, height: containerHeight)
                .dashedBorder(color: .accentColor)
                .scaleEffect(scale)
                .frame(width: containerWidth * scale, height: containerHeight * scale)

            tipsBar
                .frame(height: tipsBarHeight)
        }
        .background(.background)
        .environment(\.colorScheme, isDarkMode ? .dark : .light)
        .frame(width: containerWidth * scale, height: toolBarHeight + tipsBarHeight + containerHeight * scale)
        .onAppear {
            // 初始化时跟随系统主题
            isDarkMode = systemColorScheme == .dark
        }
        .withMagicToast()
        .toolbar {
            ToolbarItem(placement: .automatic) {
                self.themeToggleButton
            }
            ToolbarItem(placement: .automatic) {
                self.screenshotButton
            }
        }
    }

    /// 更新容器尺寸
    /// - Parameter newSize: 新的容器尺寸
    func updateContainerSize(_ newSize: CGSize) {
        containerSize = newSize
    }

    /// 更新缩放比例
    /// - Parameter newScale: 新的缩放比例
    func updateScale(_ newScale: CGFloat) {
        scale = newScale
    }
}

#Preview("iMac 27 - 20%") {
    GeometryReader { geo in
        Text("Hello, World!")
            .font(.system(size: geo.size.width * 0.1))
            .magicCentered()
            .background(.orange.opacity(0.3))
    }
    .inMagicContainer(.iMac27, scale: 0.2)
}

#Preview("iMac 27 - 10%") {
    GeometryReader { geo in
        Text("Hello, World!")
            .font(.system(size: geo.size.width * 0.1))
            .magicCentered()
            .background(.orange.opacity(0.3))
    }
    .inMagicContainer(.iMac27, scale: 0.1)
}
