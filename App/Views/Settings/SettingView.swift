import SwiftUI

struct SettingView: View {
    var body: some View {
        ScrollView {
            VStack {
                DirSetting().padding()
                CoverDirSetting().padding()
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
