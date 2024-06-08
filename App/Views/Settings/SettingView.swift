import SwiftUI

struct SettingView: View {
    var body: some View {
        ScrollView {
            VStack {
                BuySetting()
                    .padding(.horizontal)
                    .padding(.top)

                DirSetting().padding(.horizontal)
//                CoverDirSetting().padding(.horizontal)
                VersionSetting().padding(.horizontal)
                
                if AppConfig.debug {
                    PlayTime().padding(.horizontal)
                }
                
                if AppConfig.isDebug {
                    DeviceSetting()
                        .padding(.horizontal)
                        .padding(.bottom)
                }
            }
        }
        .modelContainer(AppConfig.getSyncedContainer)
    }
}

#Preview {
    SettingView()
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}
