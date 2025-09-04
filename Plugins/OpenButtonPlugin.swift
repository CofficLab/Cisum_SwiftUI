import MagicCore
import OSLog
import SwiftUI

actor OpenButtonPlugin: SuperPlugin {
    let label = "OpenButton"
    let hasPoster = false
    let description: String = "当前资源打开按钮"
    let iconName: String = .iconFinder
    nonisolated(unsafe) var enabled = true

    #if os(macOS)
        @MainActor
        func addToolBarButtons() -> [(id: String, view: AnyView)] {
            guard enabled else { return [] }
            return [(id: "open-current", view: AnyView(OpenCurrentButtonView()))]
        }
    #endif
}

private struct OpenCurrentButtonView: View, SuperLog {
    nonisolated static let emoji = "😜"
    
    @EnvironmentObject var man: PlayManController

    @State private var url: URL? = nil

    var body: some View {
        os_log("\(self.t)开始渲染")
        return Group {
            if let url = url {
                url.makeOpenButton()
                    .magicShapeVisibility(.onHover)
                    .magicSize(.small)
                    .id(url.absoluteString)
            }
        }
        .onPlayManAssetChanged({
            self.url = $0
        })
        .onAppear {
            if let url = man.getAsset() {
                self.url = url
            }
        }
    }
}

// MARK: - Preview

#if os(macOS)
    #Preview("App - Large") {
        AppPreview()
            .frame(width: 600, height: 1000)
    }

    #Preview("App - Small") {
        AppPreview()
            .frame(width: 500, height: 800)
    }
#endif

#if os(iOS)
    #Preview("iPhone") {
        AppPreview()
    }
#endif
