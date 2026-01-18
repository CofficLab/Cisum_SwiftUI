import MagicKit
import SwiftUI

struct RootToolbar: ToolbarContent {
    @EnvironmentObject var p: PluginProvider

    var body: some ToolbarContent {
        Group {
            Group {
                if p.groupPlugins.count > 1 {
                    ToolbarItem(placement: .navigation) {
                        BtnScene()
                    }
                }

                ToolbarItemGroup(placement: .cancellationAction) {
                    Spacer()

                    ForEach(p.getToolBarButtons(), id: \.id) { item in
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
