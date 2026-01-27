import MagicKit
import OSLog
import StoreKit
import SwiftUI

struct PurchaseView: View, SuperLog {
    nonisolated static let emoji = "🛒"
    nonisolated static let verbose = false

    @Environment(\.colorScheme) var colorScheme: ColorScheme

    var showSubscription: Bool = true
    var showOneTime: Bool = false
    var showNonRenewable: Bool = false
    var showConsumable: Bool = false

    init(showSubscription: Bool = true,
         showOneTime: Bool = false,
         showNonRenewable: Bool = false,
         showConsumable: Bool = false) {
        self.showSubscription = showSubscription
        self.showOneTime = showOneTime
        self.showNonRenewable = showNonRenewable
        self.showConsumable = showConsumable
    }

    var body: some View {
        SheetContainer {
            // 商品分组
            if enabledProductGroupCount > 1 {
                productTabs
            } else {
                singleProductGroup
            }

            // 底部链接
            HStack(spacing: 20) {
                Link(destination: URL(string: "https://www.kuaiyizhi.cn/privacy")!) {
                    Label("隐私政策", systemImage: "hand.raised.fill")
                        .font(.footnote)
                }

                Divider()
                    .frame(height: 12)

                Link(destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!) {
                    Label("许可协议", systemImage: "doc.text.fill")
                        .font(.footnote)
                }
            }
            .foregroundStyle(.secondary)
            .buttonStyle(.plain)
            .padding(.vertical, 16)
            .infiniteWidth()
        }
    }

    // MARK: - 子视图组件

    /// 多个商品组的TabView
    private var productTabs: some View {
        TabView {
            if showSubscription {
                ProductsSubscription()
                    .tabItem { Label("订阅", systemImage: .iconRepeatAll) }
            }

            if showOneTime {
                ProductsOfOneTime()
                    .tabItem { Label("一次性购买", systemImage: .iconRepeat1) }
            }

            if showNonRenewable {
                ProductsNonRenewable()
                    .tabItem { Label("非续订", systemImage: .iconClock) }
            }

            if showConsumable {
                ProductsConsumable()
                    .tabItem { Label("消耗品", systemImage: .iconDoc) }
            }
        }
        .infinite()
        .shadowSm()
    }

    /// 单个商品组展示
    private var singleProductGroup: some View {
        Group {
            if showSubscription {
                ProductsSubscription()
            } else if showOneTime {
                ProductsOfOneTime()
            } else if showNonRenewable {
                ProductsNonRenewable()
            } else if showConsumable {
                ProductsConsumable()
            }
        }
    }

    // MARK: - Computed Properties

    private var enabledProductGroupCount: Int {
        [showSubscription, showOneTime, showNonRenewable, showConsumable].filter { $0 }.count
    }
}

// MARK: - Preview

#Preview("PurchaseView - All") {
    PurchaseView()
        .inRootView()
        .frame(height: 800)
}

#Preview("PurchaseView - Subscription Only") {
    PurchaseView(showSubscription: true,
                 showOneTime: false,
                 showNonRenewable: false,
                 showConsumable: false)
        .inRootView()
        .frame(height: 800)
}

#Preview("Store Debug") {
    DebugView()
        .inRootView()
        .frame(width: 500, height: 700)
}

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
