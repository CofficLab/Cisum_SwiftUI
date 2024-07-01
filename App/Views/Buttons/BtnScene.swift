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
    }
}

#Preview("APP") {
    AppPreview()
        .frame(height: 800)
}
