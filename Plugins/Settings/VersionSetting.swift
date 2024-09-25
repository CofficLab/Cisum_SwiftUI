import SwiftUI
import MagicKit

struct VersionSetting: View {
    var body: some View {
        GroupBox {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("版本").font(.headline)
                    if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                        Text(appVersion)
                            .font(.footnote)
                    } else {
                        Text("版本号未知")
                    }
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(10)
        }
        .background(BackgroundView.type1.opacity(0.1))
    }
}

#Preview {
    VersionSetting()
}
