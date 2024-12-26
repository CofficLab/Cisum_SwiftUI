import SwiftUI
import MagicKit

struct VersionSetting: View, SuperSetting {
    var body: some View {
        makeSettingView(title: "🔮 版本") {
            if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                Text(appVersion)
                    .font(.footnote)
            } else {
                Text("版本号未知")
            }
        }
    }
}
#Preview {
    VersionSetting()
}
