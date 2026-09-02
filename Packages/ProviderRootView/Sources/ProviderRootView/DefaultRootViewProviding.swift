import CisumKernel
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
    let kernel: CisumKernel
    @State private var isDetailVisible = true

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                controlArea
                    .frame(height: isDetailVisible ? min(420, max(320, geometry.size.height * 0.48)) : nil)

                if isDetailVisible {
                    contentArea
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                statusArea
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .background(.background)
        .toolbar {
            ToolbarItem(placement: .navigation) {
                toolbarArea
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    withAnimation(.easeInOut(duration: 0.22)) {
                        isDetailVisible.toggle()
                    }
                } label: {
                    Label(
                        isDetailVisible ? "隐藏内容" : "显示内容",
                        systemImage: "rectangle.bottomhalf.inset.filled"
                    )
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
        }
    }

    @ViewBuilder
    private var toolbarArea: some View {
        if let toolbarContent = provider.toolbarContent {
            toolbarContent
        }
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
