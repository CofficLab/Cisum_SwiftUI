import MagicCore
import MagicUI
import OSLog
import SwiftData
import SwiftUI

struct BtnScene: View {
    @EnvironmentObject var p: PluginProvider

    @State var isPresented: Bool = false

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
    AppPreview()
        .frame(width: 600, height: 1000)
}

#Preview("App - Small") {
    AppPreview()
        .frame(width: 500, height: 800)
}
#endif

#if os(iOS)
    #Preview("iPhone") {
        AppPreview()
    }
#endif
