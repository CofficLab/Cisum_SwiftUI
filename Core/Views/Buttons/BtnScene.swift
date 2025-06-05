import MagicCore
import OSLog
import SwiftData
import SwiftUI

struct BtnScene: View {
    @EnvironmentObject var p: PluginProvider

    @State var isPresented: Bool = false

    var body: some View {
        if let plugin = p.current {
            MagicButton(
                icon: plugin.iconName,
                title: plugin.description,
                popoverContent: AnyView(
                    Posters(
                        isPresented: $isPresented
                    )
                    .frame(minWidth: Config.minWidth)
                )
            )
        }
    }
}

#Preview("APP") {
    AppPreview()
        .frame(height: 800)
}
