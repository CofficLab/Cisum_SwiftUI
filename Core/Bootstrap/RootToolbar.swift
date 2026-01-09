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
