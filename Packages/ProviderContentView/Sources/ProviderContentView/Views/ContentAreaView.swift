import CisumUIComponents
import SwiftUI

/// 内容 Tab 容器视图。
///
/// 展示已注入的 Tab 视图；尚未注入任何 Tab 时展示占位说明。
struct ContentAreaView: View {
    @ObservedObject var provider: DefaultContentViewProvider
    @LumiTheme private var appTheme
    @State private var selectedTab = 0
    @Environment(\.demoMode) private var isDemoMode

    private var tabs: [ContentTabItem] { provider.tabs }

    var body: some View {
        Group {
            if isDemoMode {
                customTabView
            } else {
                regularTabView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(appTheme.background)
        .onChange(of: tabs.count) { _, newCount in
            if selectedTab >= newCount { selectedTab = max(0, newCount - 1) }
        }
    }

    @ViewBuilder
    private var regularTabView: some View {
        if tabs.isEmpty {
            EmptyTabView()
        } else {
            #if os(macOS)
                if #available(macOS 15.0, *) {
                    tabView
                        .tabViewStyle(GroupedTabViewStyle())
                        .padding(.top, 2)
                } else {
                    tabView
                        .padding(.top, 2)
                }
            #else
                tabView
            #endif
        }
    }

    private var tabView: some View {
        TabView(selection: $selectedTab) {
            ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                tab.content
                    .tag(index)
                    .tabItem { Label(tab.title, systemImage: "music.note") }
            }
        }
    }

    private var customTabView: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                    Button {
                        withAnimation { selectedTab = index }
                    } label: {
                        Text(tab.title)
                            .font(.caption)
                            .lineLimit(1)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 8)
                            .foregroundStyle(selectedTab == index ? appTheme.primary : appTheme.textSecondary)
                            .background(
                                selectedTab == index ? appTheme.primary.opacity(0.1) : .clear,
                                in: RoundedRectangle(cornerRadius: 8)
                            )
                    }
                    .buttonStyle(.plain)
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 0)
            .background(appTheme.textSecondary.opacity(0.1))

            if let tab = tabs[safe: selectedTab] {
                tab.content
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
            } else {
                EmptyTabView()
            }
        }
    }
}

private extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
