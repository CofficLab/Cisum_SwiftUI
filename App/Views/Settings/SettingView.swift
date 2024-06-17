import SwiftUI

struct SettingView: View {
    var body: some View {
        ScrollView {
            VStack {
                BuySetting()
                    .padding(.horizontal)
                    .padding(.top)

                DirSetting().padding(.horizontal)
                CloudSetting().padding(.horizontal)
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
    RootView {
        SettingView()
            .background(.background)
    }
    .modelContainer(AppConfig.getContainer)
    .frame(height: 800)
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}
