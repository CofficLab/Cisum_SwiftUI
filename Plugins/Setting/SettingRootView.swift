import SwiftUI

struct SettingRootView: View {
    @EnvironmentObject var c: ConfigProvider

    var body: some View {
        if c.storageLocation == nil {
            SettingPluginView()
        }
    }
}
