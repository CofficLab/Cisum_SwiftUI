import CisumUIComponents
import KernelCore
import SwiftUI

/// 根布局视图（迁移自 FactoryCisum `AppLayoutView`）。
///
/// 结构：顶部播放控制区 + 中间内容区 + 底部状态区；工具栏含场景切换器与
/// 「显示/隐藏内容」按钮。各区域优先使用 Provider 注入的视图，否则回退默认实现。
struct RootLayoutView: View {
    @ObservedObject private var viewModel: RootLayoutViewModel
    @ObservedObject private var themeRegistry = LumiUIThemeRegistry.shared
    let provider: DefaultRootViewProviding
    let kernel: CisumKernel
    @State private var isDetailVisible = false
    @State private var rememberedHeight: CGFloat = 0
    @State private var autoResizing = false

    init(provider: DefaultRootViewProviding, kernel: CisumKernel) {
        _viewModel = ObservedObject(wrappedValue: RootLayoutViewModel(provider: provider))
        self.provider = provider
        self.kernel = kernel
    }

    private var isContentVisible: Bool { viewModel.isContentViewVisible }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                themeRegistry.chromeTheme.makeGlobalBackground(proxy: geometry)

                VStack(spacing: 0) {
                    controlArea
                        .frame(height: isDetailVisible ? 250 : geometry.size.height)

                    if isDetailVisible {
                        contentArea
                    }

                    statusArea
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
            .onAppear { handleOnAppear() }
            .onChange(of: viewModel.isContentViewVisible) { _, newValue in
                handleContentViewVisibilityChange(newValue, geometry: geometry)
            }
            .onChange(of: geometry.size.height) { _, newHeight in
                handleGeometryChange(newHeight)
            }
        }
        .appThemedAppearance()
        .toolbar {
            ToolbarItem(placement: .navigation) {
                toolbarArea
            }
            if !(kernel.plugin?.getToolBarButtons() ?? []).isEmpty {
                ToolbarItemGroup(placement: .cancellationAction) {
                    Spacer()
                    ForEach(Array((kernel.plugin?.getToolBarButtons() ?? []).enumerated()), id: \.offset) { _, item in
                        item.view
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var controlArea: some View {
        if let controlView = viewModel.controlView {
            controlView
            #if DEBUG
                .overlay(alignment: .topTrailing) {
                    DebugViewBadge(text: "ControlView")
                        .padding(8)
                }
            #endif
        } else {
            ContentPlaceholderView()
        }
    }

    @ViewBuilder
    private var contentArea: some View {
        if let contentView = viewModel.contentView {
            contentView
            #if DEBUG
                .overlay(alignment: .topTrailing) {
                    DebugViewBadge(text: "ContentView")
                        .padding(8)
                }
            #endif
        } else {
            ContentPlaceholderView()
        }
    }

    @ViewBuilder
    private var statusArea: some View {
        if let statusView = viewModel.statusView {
            statusView
        } else {
            HStack {
                Spacer()
                ForEach(Array((kernel.plugin?.getStatusViews() ?? []).enumerated()), id: \.offset) { _, view in
                    view
                }
            }
        }
    }

    @ViewBuilder
    private var toolbarArea: some View {
        if let toolbarContent = viewModel.toolbarContent {
            toolbarContent
        }
    }

    private func handleOnAppear() {
        rememberedHeight = windowHeight()
        isDetailVisible = isContentVisible
    }

    private func handleContentViewVisibilityChange(_ newValue: Bool, geometry: GeometryProxy) {
        withAnimation {
            isDetailVisible = newValue
        }

        if !newValue, geometry.size.height != rememberedHeight, rememberedHeight > 0 {
            autoResizing = true
            setWindowHeight(rememberedHeight)
        } else if newValue, geometry.size.height - 250 <= 200 {
            autoResizing = true
            setWindowHeight(450)
        }
    }

    private func handleGeometryChange(_ newHeight: CGFloat) {
        if !autoResizing {
            rememberedHeight = windowHeight()
        }
        autoResizing = false

        if newHeight <= 270 {
            provider.hideContentView()
        }
    }

    private func windowHeight() -> CGFloat {
        #if os(macOS)
            NSApplication.shared.windows.first?.frame.height ?? 0
        #else
            0
        #endif
    }

    private func setWindowHeight(_ height: CGFloat) {
        #if os(macOS)
            guard let window = NSApplication.shared.windows.first else { return }
            var frame = window.frame
            frame.origin.y += frame.height - height
            frame.size.height = height
            window.setFrame(frame, display: true)
        #else
            _ = height
        #endif
    }
}

/// 调试徽章 —— 仅 DEBUG 构建下由根视图叠加在内容区右上角，
/// 用于快速识别当前渲染的内容视图。
#if DEBUG
private struct DebugViewBadge: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .foregroundStyle(.white)
            .background(.red.opacity(0.85), in: Capsule())
            .overlay(Capsule().strokeBorder(.white.opacity(0.5), lineWidth: 0.5))
            .shadow(color: .black.opacity(0.25), radius: 3, y: 1)
            .allowsHitTesting(false)
    }
}
#endif
