import OSLog
import SwiftData
import SwiftUI

struct BtnScene: View {
    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var data: DataProvider
    
    @State var isPresented: Bool = false

    var body: some View {
        ControlButton(
            title: "打开",
            image: data.appScene.iconName,
            dynamicSize: false,
            onTap: {
                self.isPresented = true
            })
        .popover(isPresented: $isPresented, content: {
            Scenes(
                selection: $data.appScene,
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
