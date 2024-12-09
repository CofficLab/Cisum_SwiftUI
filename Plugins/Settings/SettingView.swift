import SwiftUI

struct SettingView: View {
    var body: some View {
        ScrollView {
            VStack {
                DirSetting()
                    .padding(.horizontal)
                
                //CloudSetting().padding(.horizontal)
                VersionSetting()
                    .padding(.horizontal)
                
//                if Config.debug {
//                    PlayTime()
//                        .padding(.horizontal)
//                }
                
//                if Config.isDebug {
//                    DeviceSetting()
//                        .padding(.horizontal)
//                        .padding(.bottom)
//                }
            }.padding(.top)
        }
        .modelContainer(Config.getSyncedContainer)
    }
}

#Preview {
    RootView {
        SettingView()
            .background(.background)
    }
    .modelContainer(Config.getContainer)
    .frame(height: 800)
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}
