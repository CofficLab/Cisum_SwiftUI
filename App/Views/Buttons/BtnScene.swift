import OSLog
import SwiftData
import SwiftUI

struct BtnScene: View {
    @EnvironmentObject var app: AppManager
    @EnvironmentObject var data: DataManager

    var body: some View {
        ControlButton(
            title: "打开",
            image: data.appScene.iconName,
            dynamicSize: false,
            onTap: {
                app.showScenes = true
            })
        .popover(isPresented: $app.showScenes, content: {
            Scenes(
                selection: $data.appScene,
                isPreseted: $app.showScenes
            )
        })
    }
}

#Preview("APP") {
    AppPreview()
        .frame(height: 800)
}
