import MagicKit

import SwiftUI

struct ResetSetting: View, SuperSetting, SuperLog {
    nonisolated static let emoji = "🫙"

    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var configProvider: ConfigProvider
    @EnvironmentObject var pluginProvider: PluginProvider
    @EnvironmentObject var m: MessageProvider

    @State var diskSize: String?

    var body: some View {
        makeSettingView(
            title: "\(Self.emoji) 重置",
            content: {
                Text("重置设置，恢复成系统默认状态")
                
                Button(action: {
                    app.setResetting(true)
                    
                    configProvider.resetStorageLocation()
                    
                    app.setResetting(false)
                }) {
                    Label("重置所有设置", systemImage: "arrow.counterclockwise")
                        .foregroundColor(.red)
                }
                .buttonStyle(.bordered)
                .padding(.top, 8)
            }
        )
    }
}
