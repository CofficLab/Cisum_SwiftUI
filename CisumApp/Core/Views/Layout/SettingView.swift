import CisumUI
import SwiftUI

struct SettingView: View {
    @EnvironmentObject var p: PluginProvider
    @LumiTheme private var appTheme

    private var settingViews: [PluginSettingView] {
        p.plugins.compactMap { plugin in
            guard let view = plugin.addSettingView() else { return nil }
            return PluginSettingView(id: plugin.id, view: view)
        }
    }

    var body: some View {
        let currentSettingViews = settingViews

        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(currentSettingViews) { settingView in
                    settingView.view
                }
            }
            .padding()
            .frame(maxWidth: 720)
            .frame(maxWidth: .infinity)
        }
        .background(appTheme.background)
    }
}

private struct PluginSettingView: Identifiable {
    let id: String
    let view: AnyView
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
