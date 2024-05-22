import SwiftUI

struct SettingView: View {
    var body: some View {
        ScrollView {
            VStack {
                DirSetting().padding(.horizontal)
                CoverDirSetting().padding(.horizontal)
                VersionSetting().padding(.horizontal)
                PlayTime().padding(.horizontal)
            }
        }
        .background(.background)
    }
}

#Preview {
    SettingView()
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}
