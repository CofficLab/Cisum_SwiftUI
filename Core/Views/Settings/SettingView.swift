import SwiftUI

struct SettingView: View {
    @EnvironmentObject var p: PluginProvider

    var body: some View {
        ScrollView {
            VStack {
                ForEach(p.plugins.indices, id: \.self) { index in
                    p.plugins[index].addSettingView().padding(.horizontal)
                }
                
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
    }
}

#Preview {
    RootView {
        SettingView()
            .background(.background)
    }
    .frame(height: 800)
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}
