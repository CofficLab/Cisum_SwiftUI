import MagicUI
import MagicKit
import MagicUI
import OSLog
import StoreKit
import SwiftUI

struct PurchaseView: View, SuperLog {
    nonisolated static let emoji = "🛒"

    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Environment(\.dismiss) private var dismiss
    @State var closeBtnHovered = false
    var showCloseButton = false
    
    // MARK: - Product Type Configuration
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
        VStack {
            // 添加关闭按钮（可配置）
            if showCloseButton {
                HStack {
                    Spacer()
                    MagicButton.simple(action: {
                        dismiss()
                    })
                    .magicIcon(.iconClose)
                    .magicShape(.circle)
                    .magicStyle(.danger)
                    .magicShapeVisibility(.always)

                    #if os(macOS)
                        .onHover { hovering in
                            closeBtnHovered = hovering
                        }
                        .scaleEffect(closeBtnHovered ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: closeBtnHovered)
                    #endif
                    #if os(iOS)
                    .scaleEffect(closeBtnHovered ? 0.9 : 1.0)
                    .animation(.easeInOut(duration: 0.1), value: closeBtnHovered)
                    .onTapGesture {
                        closeBtnHovered = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            closeBtnHovered = false
                        }
                    }
                    #endif
                }
                .padding(.vertical, 2)
            }

            // 商品分组
            TabView {
                if showSubscription {
                    ProductsSubscription()
                        .tabItem { Label("订阅", systemImage: "repeat") }
                }
                
                if showOneTime {
                    ProductsOfOneTime()
                        .tabItem { Label("一次性购买", systemImage: "car") }
                }

                if showNonRenewable {
                    ProductsNonRenewable()
                        .tabItem { Label("非续订", systemImage: "clock") }
                }

                if showConsumable {
                    ProductsConsumable()
                        .tabItem { Label("消耗品", systemImage: "drop") }
                }
            }
            .padding()
            .background(MagicBackground.ocean.opacity(0.1))

            RestoreView()
                .padding()
                .background(MagicBackground.aurora.opacity(0.1))

            footerView
        }
        .padding()
    }

    // MARK: Footer

    private var footerView: some View {
        HStack {
            Spacer()
            Link("隐私政策", destination: URL(string: "https://www.kuaiyizhi.cn/privacy")!)
            Link("许可协议", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
            Spacer()
        }
        .foregroundStyle(
            colorScheme == .light ?
                .black.opacity(0.8) :
                .white.opacity(0.8))
        .padding(.vertical, 12)

        .font(.footnote)
        .background(MagicBackground.aurora.opacity(0.1))
    }
}

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
