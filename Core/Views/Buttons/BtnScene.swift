import OSLog
import SwiftData
import SwiftUI

struct BtnScene: View {
    @EnvironmentObject var p: PluginProvider
    
    @State var isPresented: Bool = false

    var body: some View {
        if let plugin = p.current {
            ControlButton(
                title: "打开",
            image: plugin.iconName,
            dynamicSize: false,
            onTap: {
                self.isPresented = true
            })
        .popover(isPresented: $isPresented, content: {
            Posters(
                isPresented: $isPresented
            )
            .frame(minWidth: Config.minWidth)
            })
        }
    }
}

#Preview("APP") {
    AppPreview()
        .frame(height: 800)
}
