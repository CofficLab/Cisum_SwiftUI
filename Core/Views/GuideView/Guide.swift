import MagicKit
import OSLog
import SwiftUI

struct Guide: View, SuperLog {
    nonisolated static let emoji = "🧭"
    nonisolated static let verbose = false

    @EnvironmentObject var pluginProvider: PluginProvider
    @State var currentGuidePageIndex: Int = 0

    private var views: [AnyView] {
        pluginProvider.plugins.compactMap { $0.addGuideView() }
    }

    var body: some View {
        ZStack {
            // 显示当前页面
            if currentGuidePageIndex < views.count {
                pluginViewWithNavigation(at: currentGuidePageIndex)
            } else {
                GuideDoneView(isActive: true)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: currentGuidePageIndex)
    }
}

// MARK: - View Builder

extension Guide {
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
                            currentGuidePageIndex = index - 1
                        }
                        .magicStyle(.warning)
                        .magicShape(.circle)
                        .magicSize(.large)
                        .magicShapeVisibility(.always)
                    }

                    // 下一页按钮
                    MagicButton.simple(icon: .iconNextPage) {
                        currentGuidePageIndex = index + 1
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
