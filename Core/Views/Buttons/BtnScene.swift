import MagicKit
import MagicUI
import OSLog
import SwiftData
import SwiftUI

struct BtnScene: View {
    @EnvironmentObject var p: PluginProvider

    @State private var isPresented: Bool = false

    var body: some View {
        if let sceneName = p.currentSceneName {
            MagicButton.simple(
                icon: sceneIcon(for: sceneName),
                title: sceneName,
            ) {
                self.isPresented.toggle()
            }
            .magicSize(.mini)
            .popover(isPresented: self.$isPresented, content: {
                Posters(
                    isPresented: $isPresented
                )
                .frame(minWidth: Config.minWidth)
            })
        }
    }

    /// 根据场景名称返回对应的图标
    private func sceneIcon(for sceneName: String) -> String {
        switch sceneName {
        case "音乐库":
            return "music.note"
        case "有声书":
            return "book"
        default:
            return "circle"
        }
    }
}

#if os(macOS)
#Preview("App - Large") {
    ContentView()
    .inRootView()
        .frame(width: 600, height: 1000)
}

#Preview("App - Small") {
    ContentView()
    .inRootView()
        .frame(width: 500, height: 800)
}
#endif

#if os(iOS)
    #Preview("iPhone") {
        ContentView()
    .inRootView()
    }
#endif
