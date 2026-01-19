import MagicKit
import MagicUI
import OSLog
import SwiftData
import SwiftUI

struct BtnScene: View {
    @EnvironmentObject var p: PluginProvider

    @State private var isPresented: Bool = false

    var body: some View {
        if let plugin = p.current {
            MagicButton.simple(
                icon: plugin.iconName,
                title: plugin.description,
            ) {
                self.isPresented.toggle()
            }
            .magicSize(.mini)
            .popover(isPresented: self.$isPresented, content: {
                Posters(
                    isPresented: $isPresented
                )
                .frame(minWidth: Config.minWidth)
            })
        }
    }
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
        .frame(width: 500, height: 800)
}
#endif

#if os(iOS)
    #Preview("iPhone") {
        ContentView()
    .inRootView()
    }
#endif
