import OSLog
import SwiftData
import SwiftUI

struct BtnScene: View {
    @EnvironmentObject var l: FamalyProvider
    
    @State var isPresented: Bool = false

    var body: some View {
        ControlButton(
            title: "打开",
            image: l.current.iconName,
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

#Preview("APP") {
    AppPreview()
        .frame(height: 800)
}
