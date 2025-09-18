import OSLog
import StoreKit
import SwiftUI

struct MySubscription: View {
    @EnvironmentObject var app: AppProvider

    @State private var error: Error? = nil
    @State private var refreshing: Bool = false
    @State private var description: String = ""
    @State private var status: RenewalState.RawValue?
    @State private var product: ProductDTO?

    private var statusDescription: String {
        guard let status = status else {
            return "无状态"
        }

        switch status {
        case RenewalState.subscribed.rawValue:
            return "订阅中"
        case RenewalState.expired.rawValue:
            return "已过期"
        case RenewalState.revoked.rawValue:
            return "被撤回"
        case RenewalState.inGracePeriod.rawValue:
            return "在账单宽限期"
        case RenewalState.inBillingRetryPeriod.rawValue:
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
        .task {
            await refresh("🐛 初始化我的订阅")
        }
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
            Task {
                await refresh("🐛 点击了我的订阅中的刷新按钮")
            }
        }, label: {
            Label(
                title: { Text("刷新") },
                icon: { Image(systemName: "arrow.clockwise") }
            ).labelStyle(.iconOnly)
        }).disabled(refreshing).buttonStyle(.plain)
    }

    private func refresh(_ reason: String) async {
        refreshing = true

        do {
            let result = try await StoreService.inspectSubscriptionStatus(reason)
            self.status = result.highestStatus?.state
            self.product = result.highestProduct
        } catch {
            self.error = error
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            refreshing = false
        })
    }
}

// MARK: - Preview

#Preview("PurchaseView") {
    PurchaseView()
        .inRootView()
        .frame(height: 800)
}

#Preview("APP") {
    ContentView()
        .inRootView()
        .frame(width: 700)
        .frame(height: 800)
}
