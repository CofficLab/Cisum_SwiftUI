import SwiftUI

public struct AppTabBar: View {
    public struct Tab: Identifiable, Equatable {
        public let id: String
        public let title: String
        public let icon: String?

        public init(title: String, icon: String? = nil, id: String? = nil) {
            self.id = id ?? title
            self.title = title
            self.icon = icon
        }
    }

    let tabs: [Tab]
    @Binding var selectedTab: String
    var showText: Bool = true

    public init(tabs: [String], selectedTab: Binding<String>) {
        self.tabs = tabs.map { Tab(title: $0) }
        self._selectedTab = selectedTab
    }

    public init(tabs: [Tab], selectedTab: Binding<String>, showText: Bool = true) {
        self.tabs = tabs
        self._selectedTab = selectedTab
        self.showText = showText
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppUI.Spacing.sm) {
                ForEach(tabs) { tab in
                    AppTabButton(
                        title: tab.title,
                        icon: tab.icon,
                        isSelected: selectedTab == tab.id,
                        showText: showText
                    ) {
                        selectedTab = tab.id
                    }
                }
            }
            .padding(.horizontal, 1)
        }
    }
}

private struct AppTabButton: View {
    @LumiTheme private var theme
    @LumiMotionPreferenceReader private var motionPreference

    let title: String
    let icon: String?
    let isSelected: Bool
    let showText: Bool
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 10))
                }
                if showText {
                    Text(title)
                        .font(AppUI.Typography.caption1)
                }
            }
            .foregroundColor(isSelected ? .white : theme.textSecondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(background)
            .cornerRadius(6)
            .scaleEffect(isHovered && !isSelected && motionPreference.allowsMotion ? AppUI.Motion.hoverScale : 1.0)
            .animation(AppUI.Motion.enabled(AppUI.Motion.selection, preference: motionPreference), value: isSelected)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            AppUI.Motion.animate(AppUI.Motion.enabled(AppUI.Motion.hover, preference: motionPreference)) {
                isHovered = hovering
            }
        }
    }

    @ViewBuilder
    private var background: some View {
        if isSelected {
            theme.primary
        } else if isHovered {
            Color.white.opacity(0.12)
        } else {
            Color.white.opacity(0.05)
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var selected = "Chat"
        var body: some View {
            VStack(spacing: 16) {
                AppTabBar(tabs: ["Chat", "Code", "Images"], selectedTab: $selected)
                AppTabBar(tabs: [
                    AppTabBar.Tab(title: "Home", icon: "house"),
                    AppTabBar.Tab(title: "Search", icon: "magnifyingglass"),
                    AppTabBar.Tab(title: "Settings", icon: "gearshape"),
                ], selectedTab: $selected, showText: false)
            }
            .padding()
            .frame(width: 300)
            .background(Color.gray.opacity(0.15))
        }
    }
    return PreviewWrapper()
}
