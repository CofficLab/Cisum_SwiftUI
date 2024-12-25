import SwiftUI
import MagicKit

struct SettingRootView: View {
    @EnvironmentObject var c: ConfigProvider

    var body: some View {
        if c.storageLocation == nil {
            ZStack {
                SettingPluginView()
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.green.opacity(0.5), lineWidth: 2)
                    )
                    .shadow(radius: 8)
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(BackgroundView.type2.opacity(0.95))
        }
    }
}
