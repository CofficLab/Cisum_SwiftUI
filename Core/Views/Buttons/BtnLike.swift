import OSLog
import SwiftUI

struct BtnLike: View {
    @EnvironmentObject var man: PlayMan
    @EnvironmentObject var m: MessageProvider

    @State var like: Bool = false

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
                                m.hub(like ? "已取消喜欢" : "已标记为喜欢")
                                self.like.toggle()
                            } catch {
                                self.m.error(error)
                            }
                        }
                    })
            } else {
                EmptyView()
            }
        }
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
