import SwiftUI

struct SettingView: View {
    @EnvironmentObject var p: PluginProvider

    var body: some View {
        ScrollView {
            VStack {
                ForEach(p.plugins.indices, id: \.self) { index in
                    p.plugins[index].addSettingView()
                }
            }.padding()
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
