import MagicKit

import SwiftUI

struct VersionSetting: View, SuperSetting {
    var body: some View {
        makeSettingView(title: "🔮 版本") {
            Text(MagicApp.getVersion())
                .font(.footnote)
        }
    }
}

#Preview {
    VersionSetting()
}
