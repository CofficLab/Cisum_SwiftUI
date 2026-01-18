import MagicKit
import OSLog
import SwiftUI

struct Launcher: View, SuperLog {
    nonisolated static let emoji = "🦭"
    nonisolated static let verbose = true

    @State var currentLaunchPageIndex: Int = 0

    let plugins: [SuperPlugin]
    private let views: [AnyView]

    init(plugins: [SuperPlugin]) {
        let views = plugins.compactMap { $0.addLaunchView() }
        self.plugins = plugins
        self.views = views
    }

    var body: some View {
        ZStack {
            // 显示当前页面
            if currentLaunchPageIndex < views.count {
                pluginViewWithNavigation(at: currentLaunchPageIndex)
            } else {
                LaunchDoneView(isActive: true)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: currentLaunchPageIndex)
    }
}

// MARK: - View Builder

extension Launcher {
    /// 生成带有导航按钮的插件视图
    /// - Parameter index: 视图索引
    /// - Returns: 包含导航按钮的插件视图
    @ViewBuilder
    private func pluginViewWithNavigation(at index: Int) -> some View {
        ZStack {
            views[index]

            // 为每个插件页面添加导航按钮
            VStack {
                Spacer()

                // 统一的导航按钮
                HStack(spacing: 16) {
                    // 上一页按钮
                    if index > 0 {
                        MagicButton.simple(icon: .iconPreviousPage) {
                            currentLaunchPageIndex = index - 1
                        }
                        .magicStyle(.warning)
                        .magicShape(.circle)
                        .magicSize(.large)
                        .magicShapeVisibility(.always)
                    }

                    // 下一页按钮
                    MagicButton.simple(icon: .iconNextPage) {
                        currentLaunchPageIndex = index + 1
                    }
                    .magicStyle(.primary)
                    .magicShape(.circle)
                    .magicSize(.large)
                    .magicShapeVisibility(.always)
                    .magicBackground(Color.primary.opacity(0.5))
                }
                .padding(.bottom, 16)
            }
        }
    }
}

// MARK: - Preview

#if os(macOS)
    #Preview("App - Large") {
        ContentView()
            .inRootView()
            .frame(width: 600, height: 1000)
    }

    #Preview("App - Small") {
        ContentView()
            .inRootView()
            .frame(width: 400, height: 700)
    }
#endif

#if os(iOS)
    #Preview("iPhone") {
        ContentView()
            .inRootView()
    }
#endif

#if os(macOS)
    #Preview("App - Large") {
        ContentView()
            .inRootView()
            .frame(width: 600, height: 1000)
    }

    #Preview("App - Small") {
        ContentView()
            .inRootView()
            .frame(width: 500, height: 800)
    }
#endif

#if os(iOS)
    #Preview("iPhone") {
        ContentView()
            .inRootView()
    }
#endif
