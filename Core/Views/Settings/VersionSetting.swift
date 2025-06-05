import MagicCore
import SwiftUI

struct VersionSetting: View, SuperSetting {
    var body: some View {
        MagicSettingSection {
            MagicSettingRow(title: "版本", description: "APP 的版本", icon: .iconVersionInfo, content: {
                Text(MagicApp.getVersion())
                    .font(.footnote)

            })
        }
    }
}

#Preview {
    VersionSetting().padding()
}
