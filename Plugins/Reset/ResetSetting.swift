import MagicKit
import SwiftUI

struct ResetSetting: View, SuperSetting, SuperLog {
    nonisolated static let emoji = "🫙"

    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var configProvider: ConfigProvider
    @EnvironmentObject var pluginProvider: PluginProvider
    @EnvironmentObject var m: MessageProvider

    var body: some View {
        MagicSettingSection {
            MagicSettingRow(title: "重置", description: "重置设置，恢复成系统默认状态", icon: .iconReset) {
                MagicButton(icon: .iconReset, action: {
                    app.setResetting(true)
                    configProvider.resetStorageLocation()
                    app.setResetting(false)
                })
                .magicShape(.circle)
                .magicSize(.small)
            }
        }
    }
}

#Preview {
    AppPreview()
}

#Preview("Setting") {
    RootView {
        SettingView()
            .background(.background)
    }
    .frame(height: 1200)
}
