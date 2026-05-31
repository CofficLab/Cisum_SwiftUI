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
            if let currentPage = currentPage(in: currentPages) {
                pluginViewWithNavigation(
                    page: currentPage.page,
                    at: currentPage.index,
                    pageCount: currentPages.count
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
    private func currentPage(in pages: [PluginGuidePage]) -> (page: PluginGuidePage, index: Int)? {
        guard !pages.isEmpty else { return nil }
        guard currentGuidePageIndex < pages.count else { return nil }

        let clampedIndex = max(currentGuidePageIndex, 0)
        return (pages[clampedIndex], clampedIndex)
    }

    /// 生成带有导航按钮的插件视图
    /// - Parameter index: 视图索引
    /// - Returns: 包含导航按钮的插件视图
    @ViewBuilder
    private func pluginViewWithNavigation(page: PluginGuidePage, at index: Int, pageCount: Int) -> some View {
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
                    if index + 1 < pageCount {
                        Image.cisumNextPage
                            .font(.title2)
                            .frame(width: 50, height: 50)
                            .background(.regularMaterial, in: Circle())
                            .cisumHoverScale(105)
                            .cisumShadowSm()
                            .cisumButton {
                                currentGuidePageIndex = index + 1
                            }
                    } else {
                        Image(systemName: "checkmark")
                            .font(.title2)
                            .frame(width: 50, height: 50)
                            .background(.regularMaterial, in: Circle())
                            .cisumHoverScale(105)
                            .cisumShadowSm()
                            .cisumButton {
                                currentGuidePageIndex = index + 1
                            }
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
