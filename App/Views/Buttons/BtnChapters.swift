import OSLog
import SwiftData
import SwiftUI

struct BtnChapters: View {
    @EnvironmentObject var app: AppManager
    @EnvironmentObject var data: DataManager

    var body: some View {
        ControlButton(
            title: "章节",
            image: data.appScene.iconName,
            dynamicSize: true,
            onTap: {
                app.showScenes = true
            })
    }
}

#Preview("APP") {
    AppPreview()
        .frame(height: 800)
}
