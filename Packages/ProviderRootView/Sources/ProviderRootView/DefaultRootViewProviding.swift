import KernelCore
import CisumUIComponents
import SwiftUI

/// 默认 `RootViewProviding` 实现：持有各区域注入视图 + 内核引用，
/// 渲染 Cisum 根布局（控制区 + 内容区 + 状态区 + 工具栏）。
@MainActor
public final class DefaultRootViewProviding: RootViewProviding, ObservableObject {
    @Published private(set) public var controlView: AnyView?
    @Published private(set) public var contentView: AnyView?
    @Published private(set) public var statusView: AnyView?
    @Published private(set) public var toolbarContent: AnyView?

    private let kernel: CisumKernel

    public init(kernel: CisumKernel) {
        self.kernel = kernel
    }

    public func setControlView(_ view: AnyView?) {
        controlView = view
    }

    public func setContentView(_ view: AnyView?) {
        contentView = view
    }

    public func setStatusView(_ view: AnyView?) {
        statusView = view
    }

    public func setToolbarContent(_ view: AnyView?) {
        toolbarContent = view
    }

    public func makeRootView() -> AnyView {
        AnyView(RootLayoutView(provider: self, kernel: kernel))
    }
}

/// 根布局视图（迁移自 FactoryCisum `AppLayoutView`）。
///
/// 结构：顶部播放控制区 + 中间内容区 + 底部状态区；工具栏含场景切换器与
/// 「显示/隐藏内容」按钮。各区域优先使用 Provider 注入的视图，否则回退默认实现。
struct RootLayoutView: View {
    @ObservedObject var provider: DefaultRootViewProviding
    @ObservedObject private var themeRegistry = LumiUIThemeRegistry.shared
    let kernel: CisumKernel
    @State private var isDetailVisible = false
    @State private var rememberedHeight: CGFloat = 0
    @State private var autoResizing = false

    private var showDB: Bool { kernel.appState?.isDBViewVisible ?? false }

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
            .onChange(of: showDB) { _, newValue in
                handleShowDBChange(newValue, geometry: geometry)
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
        if let controlView = provider.controlView {
            controlView
        } else {
            ContentPlaceholderView()
        }
    }

    @ViewBuilder
    private var contentArea: some View {
        if let contentView = provider.contentView {
            contentView
        } else {
            ContentPlaceholderView()
        }
    }

    @ViewBuilder
    private var statusArea: some View {
        if let statusView = provider.statusView {
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
        if let toolbarContent = provider.toolbarContent {
            toolbarContent
        }
    }

    private func handleOnAppear() {
        rememberedHeight = windowHeight()
        isDetailVisible = showDB
    }

    private func handleShowDBChange(_ newValue: Bool, geometry: GeometryProxy) {
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
            kernel.appState?.closeDBView()
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

/// 内容区未注入时的占位视图。
private struct ContentPlaceholderView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "music.note.list")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("暂无内容")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
