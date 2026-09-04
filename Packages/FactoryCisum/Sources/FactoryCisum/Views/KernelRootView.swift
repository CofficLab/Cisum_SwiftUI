import CisumUIComponents
import Foundation
import KernelCore
import MagicPlayMan
import SwiftUI

/// Factory 根视图桥接层。
///
/// 将内核 Provider 投影为 SwiftUI 环境值/环境对象，供仍以旧式环境读取的插件视图
/// 继续工作；并用插件的 RootView 包裹内部布局。Host 桥接彻底移除后，这里的兼容
/// 环境可进一步精简。
struct KernelRootView: View {
    @ObservedObject var kernel: CisumKernel
    @ObservedObject private var themeRegistry = LumiUIThemeRegistry.shared
    /// 插件贡献版本号：插件启用/禁用变化时 +1，触发根视图重新组装。
    @State private var contributionRevision = 0
    /// 已组装的根视图。组装会更新各个 ObservableObject Provider，不能在 body 求值期间执行。
    @State private var assembledContent: AnyView?

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    themeRegistry.chromeTheme.makeGlobalBackground(proxy: geometry)
                        .ignoresSafeArea()

                    rootContent
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .frame(minWidth: 350, minHeight: 250)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .appThemedAppearance()
#if os(macOS)
        .overlay { ThemeWindowAppearanceBridge().allowsHitTesting(false) }
#endif
        .task(id: contributionRevision) {
            assembledContent = FactoryCisum.assembleMainView(kernel: kernel)
        }
        .onReceive(NotificationCenter.default.publisher(for: .cisumEnabledPluginsDidChange)) { _ in
            contributionRevision += 1
        }
    }

    @ViewBuilder
    private var rootContent: some View {
        if let assembledContent {
            let bridged = wrap(assembledContent)
            // 插件贡献变化（.id 变化）时整棵子树重建，重新注入内容 Tab 等。
            .id(contributionRevision)
            .environment(\.demoMode, kernel.appState?.isDemoMode ?? false)
            .environment(
                \.appIsImporting,
                Binding(
                    get: { kernel.appState?.isImporting ?? false },
                    set: { kernel.appState?.setImporting($0) }
                )
            )
            .environment(\.showAudioDBViewAction, { kernel.appState?.showDBView() })
            .environment(\.pluginThemes, kernel.theme?.allThemeContributions ?? [])
            .environment(\.currentPluginThemeId, kernel.theme?.selectedThemeID ?? "")
            .environment(\.selectPluginThemeAction, { themeID in kernel.theme?.selectTheme(themeID) })
            .environment(\.resetSettingsAction, {
                Task { @MainActor in
                    FactoryCisum.mainKernel?.storage?.resetStorageLocation()
                }
            })
            if let playMan = kernel.playback as? MagicPlayMan {
                bridged.environmentObject(playMan)
            } else {
                bridged
            }
        } else {
            ProgressView("Loading…")
        }
    }

    @ViewBuilder
    private func wrap(_ content: AnyView) -> some View {
        if let wrapped = kernel.plugin?.wrapWithCurrentRoot(content: { content }) {
            wrapped
        } else {
            content
        }
    }
}
