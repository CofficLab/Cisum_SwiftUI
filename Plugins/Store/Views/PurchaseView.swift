import MagicKit
import OSLog
import StoreKit
import SwiftUI

struct PurchaseView: View, SuperLog {
    nonisolated static let emoji = "🛒"
    nonisolated static let verbose = false

    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Environment(\.dismiss) private var dismiss
    @State var closeBtnHovered = false
    var showCloseButton = false

    var showSubscription: Bool = true
    var showOneTime: Bool = false
    var showNonRenewable: Bool = false
    var showConsumable: Bool = false

    init(showCloseButton: Bool = false,
         showSubscription: Bool = true,
         showOneTime: Bool = false,
         showNonRenewable: Bool = false,
         showConsumable: Bool = false) {
        self.showCloseButton = showCloseButton
        self.showSubscription = showSubscription
        self.showOneTime = showOneTime
        self.showNonRenewable = showNonRenewable
        self.showConsumable = showConsumable
    }

    var body: some View {
        VStack(spacing: 24) {
            // 添加关闭按钮（可配置）
            if showCloseButton {
                HStack {
                    Spacer()
                    closeButton
                }
                .padding(.top, 8)
            }

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
        .padding()
    }

    // MARK: - 子视图组件

    /// 关闭按钮 - 现代化圆形设计
    private var closeButton: some View {
        Button(action: { dismiss() }) {
            Image.close
                .font(.system(size: 12, weight: .medium))
                .frame(width: 32, height: 32)
                .foregroundStyle(.secondary)
                .background(.ultraThinMaterial, in: Circle())
                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
        }
        .buttonStyle(.plain)
        #if os(macOS)
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.2)) {
                    closeBtnHovered = hovering
                }
            }
            .scaleEffect(closeBtnHovered ? 1.1 : 1.0)
        #endif
        #if os(iOS)
        .scaleEffect(closeBtnHovered ? 0.95 : 1.0)
        .onTapGesture {
            withAnimation(.easeOut(duration: 0.1)) {
                closeBtnHovered = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation { closeBtnHovered = false }
            }
        }
        #endif
    }

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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
        )
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
    PurchaseView(showCloseButton: false)
        .inRootView()
        .frame(height: 800)
}

#Preview("PurchaseView - Subscription Only") {
    PurchaseView(showCloseButton: false,
                 showSubscription: true,
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
