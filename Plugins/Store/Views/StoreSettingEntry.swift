import Foundation
import MagicCore
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
            BuySetting()
        }
    }
}

#Preview("Setting") {
    RootView {
        SettingView()
            .background(.background)
    }
    .frame(height: 800)
}

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
#Preview("App - iPhone") {
    AppPreview()
}
#endif
