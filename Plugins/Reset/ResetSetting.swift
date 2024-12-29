import MagicKit
import MagicUI
import SwiftUI

struct ResetSetting: View, SuperSetting, SuperLog {
    static let emoji = "🫙"

    @EnvironmentObject var configProvider: ConfigProvider

    @State var diskSize: String?

    var body: some View {
        makeSettingView(
            title: "\(Self.emoji) 重置",
            content: {
                Text("重置设置，恢复成系统默认状态")
                
                Button(action: {
                    configProvider.resetStorageLocation()
                    MagicApp.quit()
                }) {
                    Label("重置所有设置并退出 APP", systemImage: "arrow.counterclockwise")
                        .foregroundColor(.red)
                }
                .buttonStyle(.bordered)
                .padding(.top, 8)
            }
        )
    }
}
