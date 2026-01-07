import MagicCore
import OSLog
import SwiftUI

actor OpenButtonPlugin: SuperPlugin, PluginRegistrant, SuperLog {
    let description: String = "当前资源打开按钮"
    let iconName: String = .iconFinder
    private static var enabled: Bool { false }
    private static var verbose: Bool { false }
    nonisolated static let emoji = "😜"

    #if os(macOS)
        @MainActor
        func addToolBarButtons() -> [(id: String, view: AnyView)] {
            return [(id: "open-current", view: AnyView(OpenCurrentButtonView()))]
        }
    #endif
}

// MARK: - PluginRegistrant
extension OpenButtonPlugin {
    @objc static func register() {
        guard Self.enabled else {
            return
        }

        Task {
            if Self.verbose {
                os_log("\(self.t)🚀🚀🚀 Register")
            }
            
            await PluginRegistry.shared.register(id: "OpenButton", order: 20) {
                OpenButtonPlugin()
            }
        }
    }
}

private struct OpenCurrentButtonView: View, SuperLog {
    nonisolated static let emoji = "😜"
    static let verbose = false
    
    @EnvironmentObject var man: PlayManController

    @State private var url: URL? = nil

    var body: some View {
        if Self.verbose {
            os_log("\(self.t)开始渲染")
        }
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
