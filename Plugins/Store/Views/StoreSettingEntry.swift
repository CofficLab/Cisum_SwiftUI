import Foundation
import MagicKit
import OSLog
import SwiftUI

struct StoreSettingEntry: View {
    @State private var showBuySheet = false

    var body: some View {
        MagicSettingSection {
            MagicSettingRow(title: "应用内购买", description: "订阅专业版，解锁所有功能", icon: "cart", content: {
                MagicButton.simple(title: "查看订阅") {
                    showBuySheet = true
                }
                .magicIcon("app.gift")
                .magicShape(.circle)
                .magicStyle(.secondary)
                .magicSize(.small)
            })
        }
        .sheet(isPresented: $showBuySheet) {
            PurchaseView(showCloseButton: true)
        }
    }
}

// MARK: - Preview

#Preview("Debug") {
    DebugView()
        .inRootView()
        .frame(height: 800)
}

#Preview("Buy") {
    PurchaseView()
        .inRootView()
        .frame(height: 800)
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
