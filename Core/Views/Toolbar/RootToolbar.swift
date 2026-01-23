import MagicKit
import SwiftUI

struct RootToolbar: ToolbarContent {
    @EnvironmentObject var p: PluginProvider

    var body: some ToolbarContent {
        // 提前计算，避免重复调用
        let sceneNames = p.sceneNames
        let toolbarButtons = p.getToolBarButtons()

        if !(sceneNames.isEmpty && toolbarButtons.isEmpty) {
            if sceneNames.count > 1 {
                ToolbarItem(placement: .navigation) {
                    BtnScene()
                }
            }

            if !toolbarButtons.isEmpty {
                ToolbarItemGroup(placement: .cancellationAction) {
                    Spacer()

                    ForEach(toolbarButtons, id: \.id) { item in
                        item.view
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#if os(macOS)
    #Preview("App - Large") {
        ContentView()
            .inRootView()
            .frame(width: 600, height: 1000)
    }

    #Preview("App - Small") {
        ContentView()
            .inRootView()
            .frame(width: 400, height: 700)
    }
#endif

#if os(iOS)
    #Preview("iPhone") {
        ContentView()
            .inRootView()
    }
#endif
