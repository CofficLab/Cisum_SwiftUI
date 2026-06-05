import PluginRegistry
import SwiftUI

struct SettingView: View {
    @EnvironmentObject var p: PluginVM
    @LumiTheme private var appTheme

    private var settingItems: [PluginSettingItem] {
        var directItems: [PluginSettingItem] = []
        for plugin in p.plugins {
            if let navigationItem = plugin.addSettingNavigationItem() {
                directItems.append(
                    PluginSettingItem(
                        id: navigationItem.id,
                        order: navigationItem.order,
                        view: AnyView(
                            PluginSettingNavigationEntry(item: navigationItem)
                        )
                    )
                )
                continue
            }

            guard let view = plugin.addSettingView() else { continue }
            directItems.append(
                PluginSettingItem(
                    id: plugin.id,
                    order: type(of: plugin).order,
                    view: view
                )
            )
        }

        return directItems.sorted { $0.order < $1.order }
    }

    var body: some View {
        let currentSettingItems = settingItems

        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(currentSettingItems) { settingItem in
                    settingItem.view
                }
            }
            .padding()
            .frame(maxWidth: 720)
            .frame(maxWidth: .infinity)
        }
        .background(appTheme.background)
    }
}

private struct PluginSettingItem: Identifiable {
    let id: String
    let order: Int
    let view: AnyView
}

private struct PluginSettingNavigationEntry: View {
    let item: PluginSettingNavigationItem

    var body: some View {
        CisumUI.MagicSettingSection {
            NavigationLink {
                item.destination
            } label: {
                PluginSettingNavigationRow(
                    title: item.title,
                    description: item.description,
                    iconName: item.iconName
                )
            }
            .buttonStyle(.plain)
        }
    }
}

private struct PluginSettingNavigationRow: View {
    let title: String
    let description: String?
    let iconName: String

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Image(systemName: iconName)
                .font(.system(size: 20))
                .foregroundStyle(.secondary)
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body)

                if let description {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .contentShape(Rectangle())
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
    }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
