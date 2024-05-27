import OSLog
import StoreKit
import SwiftUI

struct MySubscription: View {
    @EnvironmentObject var store: StoreManager
    @EnvironmentObject var app: AppManager

    @State private var error: Error? = nil
    @State private var refreshing: Bool = false
    @State private var description: String = ""

    private var status: Product.SubscriptionInfo.RenewalState? {
        store.subscriptionGroupStatus
    }
    
    private var product: Product? {
        store.currentSubscription
    }
    
    private var statusDescription: String {
        guard let status = status else {
            return "无状态"
        }

        switch status {
        case .subscribed:
            return "订阅中"
        case .expired:
            return "已过期"
        case .revoked:
            return "被撤回"
        case .inGracePeriod:
            return "在账单宽限期"
        case .inBillingRetryPeriod:
            return "在账单支付期，App Store 会自动扣费"
        default:
            return "状态未知"
        }
    }
    
    private var productDescription: String {
        guard let product = product else {
            return "无订阅产品"
        }
        
        return product.displayName
    }

    var body: some View {
        GroupBox {
            VStack {
                header
                if status != nil {
                    Divider()
                    Spacer()
                    Text(statusDescription)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .center)
                    Text(productDescription)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .onChange(of: store.purchasedSubscriptions, {
            refresh("🐛 已购订阅变了")
        })
    }
    
    private var header: some View {
        ZStack {
            if status != nil {
                Text("已订阅").font(.title3)
            } else {
                Text("现在没有订阅").font(.title3)
            }
            
            HStack {
                Spacer()
                ZStack {
                    if refreshing {
                        ProgressView().scaleEffect(0.4)
                    } else {
                        refreshButton
                    }
                }.frame(width: 30, height: 10)
            }
        }
    }

    // MARK: 刷新按钮

    private var refreshButton: some View {
        Button(action: {
            refresh("🐛 点击了我的订阅中的刷新按钮")
        }, label: {
            Label(
                title: { Text("刷新") },
                icon: { Image(systemName: "arrow.clockwise") }
            ).labelStyle(.iconOnly)
        }).disabled(refreshing).buttonStyle(.plain)
    }
    
    private func refresh(_ reason: String) {
        refreshing = true
        Task {
            await store.updatePurchased(reason)
            await store.updateSubscriptionStatus(reason)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                refreshing = false
            })
        }
    }
}

#Preview {
    RootView {
        BuyView()
    }
    #if os(macOS)
    .frame(height: 400)
    #endif
}
