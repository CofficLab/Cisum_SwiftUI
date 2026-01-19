import MagicKit
import SwiftUI

struct BtnAdd: View {
    @EnvironmentObject var app: AppProvider

    var body: some View {
        Button(
            action: { app.isImporting = true },
            label: {
                Label(
                    title: { Text("添加") },
                    icon: { Image(systemName: "plus.circle") }
                )
            }
        )
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
            .frame(width: 600, height: 600)
    }
#endif

#if os(iOS)
    #Preview("iPhone") {
        ContentView()
    .inRootView()
    }
#endif
