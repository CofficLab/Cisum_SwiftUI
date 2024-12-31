import OSLog
import SwiftUI

struct BtnLike: View {
    @EnvironmentObject var man: PlayMan
    @EnvironmentObject var m: MessageProvider

    var like: Bool { man.asset?.like ?? false}
    var autoResize = false
    var title: String { like ? "取消喜欢" : "标记喜欢" }

    var body: some View {
        Group {
            if man.hasAsset {
                ControlButton(
                    title: title,
                    image: getImageName(),
                    dynamicSize: autoResize,
                    onTap: {
                        Task {
                            do {
                                try await man.toggleLike()
                                m.hub(like ? "已标记为喜欢" : "已取消喜欢")
                            } catch {
                                self.m.error(error)
                            }
                        }
                    })
            } else {
                EmptyView()
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
