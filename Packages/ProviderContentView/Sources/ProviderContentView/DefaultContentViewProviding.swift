import SwiftUI

/// 默认 `ContentViewProviding` 实现：持有注入的 Tab 列表，渲染内容区 Tab 容器
/// （迁移自 FactoryCisum `AppTabView`）。
@MainActor
public final class DefaultContentViewProviding: ContentViewProviding, ObservableObject {
    @Published public private(set) var tabs: [ContentTabItem] = []

    public init() {}

    public func setTabs(_ tabs: [ContentTabItem]) {
        self.tabs = tabs.sorted { $0.order < $1.order }
    }

    public func makeContentView() -> AnyView {
        AnyView(ContentAreaView(provider: self))
    }
}

/// 内容 Tab 容器视图。
///
/// 展示已注入的 Tab 视图；尚未注入任何 Tab 时展示占位说明。
struct ContentAreaView: View {
    @ObservedObject var provider: DefaultContentViewProviding
    @State private var selectedTab = 0

    private var tabs: [ContentTabItem] { provider.tabs }

    var body: some View {
        VStack(spacing: 0) {
            tabBar
            Divider()
            tabContent
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.background.secondary)
        .onChange(of: tabs.count) { _, newCount in
            if selectedTab >= newCount { selectedTab = max(0, newCount - 1) }
        }
    }

    private var tabBar: some View {
        HStack(spacing: 4) {
            ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                TabButton(title: tab.title, icon: "music.note", isSelected: selectedTab == index) {
                    withAnimation(.easeInOut(duration: 0.16)) {
                        selectedTab = index
                    }
                }
            }
            Spacer()
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background(.background)
    }

    @ViewBuilder
    private var tabContent: some View {
        if tabs.isEmpty {
            EmptyTabView()
        } else if let tab = tabs[safe: selectedTab] {
            tab.content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

private struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.callout.weight(isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor.opacity(0.12) : .clear, in: Capsule())
        }
        .buttonStyle(.plain)
    }
}

private struct EmptyTabView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "music.note.list")
                .font(.system(size: 40, weight: .light))
                .foregroundStyle(.tertiary)
            Text("当前场景暂无可用内容")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
