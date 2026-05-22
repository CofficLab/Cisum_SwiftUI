import CisumUI
import MagicKit
import OSLog
import StoreKit
import SwiftUI

struct PurchaseView: View, SuperLog {
    nonisolated static let emoji = "🛒"
    nonisolated static let verbose = false

    var body: some View {
        SheetContainer {
            VStack {
                AppSheetPanel {
                    VStack(spacing: 16) {
                        AppSheetIconHeader(systemImage: "giftcard.fill", title: nil as String?, tint: .blue)
                    // 版本对比
                        VersionComparisonView()

                    // 商品
                        ProductsSubscription(showHeader: false)
                    }
                }

                // Bottom links
                HStack(spacing: 20) {
                    Link(destination: URL(string: "https://www.kuaiyizhi.cn/privacy")!) {
                        Label {
                            Text("Privacy Policy", tableName: "Store")
                        } icon: {
                            Image(systemName: "hand.raised.fill")
                        }
                            .font(.footnote)
                    }

                    Divider()
                        .frame(height: 12)

                    Link(destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!) {
                        Label {
                            Text("License Agreement", tableName: "Store")
                        } icon: {
                            Image(systemName: "doc.text.fill")
                        }
                            .font(.footnote)
                    }
                }
                .foregroundStyle(.secondary)
                .buttonStyle(.plain)
                .padding(.vertical, 16)
                .infiniteWidth()
            }
            .px2()
        }
    }
}

// MARK: - Preview

#Preview("PurchaseView") {
    PurchaseView()
        .inRootView()
        .frame(height: 800)
}

#Preview("Store Debug") {
    DebugView()
        .inRootView()
        .frame(width: 500, height: 700)
}

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
