import CisumKernel
import SwiftUI

/// 内容 Tab 容器。
///
/// 展示插件贡献的 Tab 视图；插件尚未提供 Tab 时展示占位说明。
struct AppTabView: View {
    let kernel: CisumKernel
    @State private var selectedTab = 0

    private var pluginTabs: [(view: AnyView, label: String)] {
        kernel.plugin?.getTabViews(
            reason: "AppTabView",
            demoMode: kernel.appState?.isDemoMode ?? false
        ) ?? []
    }

    var body: some View {
        VStack(spacing: 0) {
            tabBar
            Divider()
            tabContent
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.background.secondary)
        .onChange(of: pluginTabs.count) { _, newCount in
            if selectedTab >= newCount { selectedTab = max(0, newCount - 1) }
        }
    }

    private var tabBar: some View {
        HStack(spacing: 4) {
            ForEach(Array(pluginTabs.enumerated()), id: \.offset) { index, tab in
                TabButton(title: tab.label, icon: "music.note", isSelected: selectedTab == index) {
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
        if pluginTabs.isEmpty {
            EmptyTabView()
        } else if let tab = pluginTabs[safe: selectedTab] {
            tab.view
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
