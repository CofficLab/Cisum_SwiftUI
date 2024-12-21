import OSLog
import SwiftUI

struct BtnLike: View {
    @EnvironmentObject var man: PlayMan
    @EnvironmentObject var m: MessageProvider

    @State var like: Bool = false
    
    var autoResize = false
    var title: String { like ? "取消喜欢" : "标记喜欢" }
    var label: String { "\(Logger.isMain)❤️ BtnLike::" }

    var body: some View {
        ControlButton(
            title: title,
            image: getImageName(),
            dynamicSize: autoResize,
            onTap: {
                do {
                    try man.toggleLike()
                    m.hub(like ? "已取消喜欢" : "已标记为喜欢")
                    self.like.toggle()
                } catch {
                    self.m.error(error)
                }
            }
        )
        .onAppear {
            self.like = man.asset?.like ?? false
        }
        .onChange(of: man.asset, {
            self.like = man.asset?.like ?? false
        })
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
