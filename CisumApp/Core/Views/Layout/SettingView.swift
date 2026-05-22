import CisumUI
import SwiftUI

struct SettingView: View {
    @EnvironmentObject var p: PluginProvider
    @LumiTheme private var appTheme

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(p.plugins.indices, id: \.self) { index in
                    p.plugins[index].addSettingView()
                }
            }
            .padding()
            .frame(maxWidth: 720)
            .frame(maxWidth: .infinity)
        }
        .background(appTheme.background)
    }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
