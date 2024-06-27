import OSLog
import SwiftUI

struct BtnLike: View {
    @EnvironmentObject var data: DataManager
    @EnvironmentObject var playMan: PlayMan

    var like: Bool { playMan.asset?.like ?? false}
    var asset: PlayAsset
    var autoResize = false
    var title: String { asset.like ? "取消喜欢" : "标记喜欢" }
    var label: String { "\(Logger.isMain)❤️ BtnLike::" }

    var body: some View {
        ZStack {
            if data.appScene == .Music {
                ControlButton(
                    title: title,
                    image: getImageName(),
                    dynamicSize: autoResize,
                    onTap: {
                        playMan.toggleLike()
                    }
                )
            }
        }
    }

    private func getImageName() -> String {
        return like ? "star.fill" : "star"
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}

#Preview("Layout") {
    LayoutView()
}
