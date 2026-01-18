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

#Preview("SettingView") {
    RootView {
        SettingView()
            .background(.background)
    }
    .frame(height: 900)
}

#if os(macOS)
#Preview("App - Large") {
    ContentView()
    .inRootView()
        .frame(width: 600, height: 1000)
}

#Preview("App - Small") {
    ContentView()
    .inRootView()
        .frame(width: 600, height: 600)
}
#endif

#if os(iOS)
#Preview("iPhone") {
    ContentView()
    .inRootView()
}
#endif
