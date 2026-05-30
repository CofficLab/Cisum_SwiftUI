import CisumUI
import MagicKit
import OSLog
import SwiftUI

struct Guide: View, SuperLog {
    nonisolated static let emoji = "🧭"
    nonisolated static let verbose = false

    @EnvironmentObject var pluginProvider: PluginProvider
    @State var currentGuidePageIndex: Int = 0

    private var pages: [PluginGuidePage] {
        pluginProvider.plugins.compactMap { plugin in
            guard let view = plugin.addGuideView() else { return nil }
            return PluginGuidePage(id: plugin.id, view: view)
        }
    }

    var body: some View {
        let currentPages = pages

        ZStack {
            // 显示当前页面
            if currentPages.indices.contains(currentGuidePageIndex) {
                pluginViewWithNavigation(
                    page: currentPages[currentGuidePageIndex],
                    at: currentGuidePageIndex
                )
            } else {
                GuideDoneView(isActive: true)
            }
        }
    }
}

private struct PluginGuidePage: Identifiable {
    let id: String
    let view: AnyView
}

// MARK: - View Builder

extension Guide {
    /// 生成带有导航按钮的插件视图
    /// - Parameter index: 视图索引
    /// - Returns: 包含导航按钮的插件视图
    @ViewBuilder
    private func pluginViewWithNavigation(page: PluginGuidePage, at index: Int) -> some View {
        ZStack {
            page.view

            // 为每个插件页面添加导航按钮
            VStack {
                Spacer()

                // 统一的导航按钮
                HStack(spacing: 16) {
                    // 上一页按钮
                    if index > 0 {
                        Image.cisumPreviousPage
                            .font(.title2)
                            .frame(width: 50, height: 50)
                            .background(.regularMaterial, in: Circle())
                            .cisumHoverScale(105)
                            .cisumShadowSm()
                            .cisumButton {
                                currentGuidePageIndex = index - 1
                            }
                    }

                    // 下一页按钮
                    Image.cisumNextPage
                        .font(.title2)
                        .frame(width: 50, height: 50)
                        .background(.regularMaterial, in: Circle())
                        .cisumHoverScale(105)
                        .cisumShadowSm()
                        .cisumButton {
                            currentGuidePageIndex = index + 1
                        }
                }
                .padding(.bottom, 16)
            }
        }
    }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
