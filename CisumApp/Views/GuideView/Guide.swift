import PluginRegistry
import OSLog
import SwiftUI

struct Guide: View, SuperLog {
    nonisolated static let emoji = "🧭"
    nonisolated static let verbose = false
    nonisolated static let previousPageLabel = String(localized: "Previous")
    nonisolated static let nextPageLabel = String(localized: "Next")
    nonisolated static let finishSetupLabel = String(localized: "Finish Setup")

    @EnvironmentObject var pluginVM: PluginVM
    @State var currentGuidePageIndex: Int = 0

    private var pages: [PluginGuidePage] {
        pluginVM.plugins.compactMap { plugin in
            guard let view = plugin.addGuideView() else { return nil }
            return PluginGuidePage(
                id: plugin.id,
                view: view,
                complete: {
                    plugin.completeGuidePage()
                }
            )
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
    let complete: @MainActor () -> Bool
}

// MARK: - View Builder

extension Guide {
    nonisolated static func visiblePageIndex(currentIndex: Int, pageCount: Int) -> Int? {
        guard pageCount > 0 else { return nil }
        return min(max(currentIndex, 0), pageCount - 1)
    }

    private func currentPage(in pages: [PluginGuidePage]) -> (page: PluginGuidePage, index: Int)? {
        guard let clampedIndex = Self.visiblePageIndex(
            currentIndex: currentGuidePageIndex,
            pageCount: pages.count
        ) else { return nil }
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
                            .accessibilityLabel(Self.previousPageLabel)
                            .help(Self.previousPageLabel)
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
                            .accessibilityLabel(Self.nextPageLabel)
                            .help(Self.nextPageLabel)
                    } else {
                        Image(systemName: "checkmark")
                            .font(.title2)
                            .frame(width: 50, height: 50)
                            .background(.regularMaterial, in: Circle())
                            .cisumHoverScale(105)
                            .cisumShadowSm()
                            .cisumButton {
                                if page.complete() {
                                    currentGuidePageIndex = index + 1
                                }
                            }
                            .accessibilityLabel(Self.finishSetupLabel)
                            .help(Self.finishSetupLabel)
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
