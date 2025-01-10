import MagicKit

import OSLog
import StoreKit
import SwiftUI

struct ProductCell: View, SuperLog {
    @EnvironmentObject var store: StoreProvider
    @State var isPurchased: Bool = false
    @State var errorTitle = ""
    @State var isShowingError: Bool = false
    @State var purchasing = false
    @State var btnHovered: Bool = false

    let product: Product
    let purchasingEnabled: Bool
    let showStatus: Bool

    var status: Product.SubscriptionInfo.Status? {
        store.status
    }

    var emoji: String {
        store.emoji(for: product.id)
    }

    var current: Product? {
        store.currentSubscription
    }

    var isCurrent: Bool {
        if let current = current {
            return current.id == product.id
        }

        return false
    }

    nonisolated static let emoji = "🖥️"

    init(product: Product, purchasingEnabled: Bool = true, showStatus: Bool = false) {
        self.product = product
        self.purchasingEnabled = purchasingEnabled
        self.showStatus = showStatus
    }

    var body: some View {
        HStack {
            // MARK: 图标

            Text(emoji)
                .font(.system(size: 30))
                .frame(width: 30, height: 30)
                .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                .padding(.trailing, 15)

            if purchasingEnabled {
                productDetail
                Spacer()
                buyButton
            } else {
                productDetail
            }
        }
        .alert(isPresented: $isShowingError, content: {
            Alert(title: Text(errorTitle), message: nil, dismissButton: .default(Text("好")))
        })
    }

    // MARK: 中间的产品介绍

    @ViewBuilder
    var productDetail: some View {
        if product.type == .autoRenewable {
            VStack(alignment: .leading) {
                Text(product.displayName)
                    .bold()
                if isCurrent {
                    Text("正在使用")
                        .font(.footnote)
                        .foregroundStyle(.green)
                }
                if isPurchased {
                    Text("已购买")
                        .font(.footnote)
                        .foregroundStyle(.green)
                }
            }
        } else {
            Text(product.description)
                .frame(alignment: .leading)
        }
    }

    // MARK: 购买按钮的提示词

    func subscribeButton(_ subscription: Product.SubscriptionInfo) -> some View {
        let unit: String
        let plural = 1 < subscription.subscriptionPeriod.value
        switch subscription.subscriptionPeriod.unit {
        case .day:
            unit = plural ? "\(subscription.subscriptionPeriod.value) 天" : "天"
        case .week:
            unit = plural ? "\(subscription.subscriptionPeriod.value) 周" : "周"
        case .month:
            unit = plural ? "\(subscription.subscriptionPeriod.value) 月" : "月"
        case .year:
            unit = plural ? "\(subscription.subscriptionPeriod.value) 年" : "年"
        @unknown default:
            unit = "period"
        }

        return Text(product.displayPrice + "/" + unit)
            .foregroundColor(.white)
            .bold()
    }

    // MARK: 购买按钮

    var buyButton: some View {
        Button(action: {
            Task {
                await buy()
            }
        }) {
            if purchasing {
                Text("支付中...")
                    .bold()
                    .foregroundColor(.white)
            } else {
                if let subscription = product.subscription {
                    subscribeButton(subscription)
                } else {
                    Text(product.displayPrice)
                        .foregroundColor(.white)
                        .bold()
                }
            }
        }
        .buttonStyle(BuyButtonStyle(isPurchased: isPurchased, hovered: btnHovered))
        .disabled(purchasing)
        .onHover(perform: { hovering in
            self.btnHovered = hovering
        })
        .onAppear(perform: onAppear)
    }

    // MARK: 去购买

    func buy() async {
//        purchasing = true
//
//        do {
//            os_log("\(self.t)点击了购买按钮")
//
//            let result = try await store.purchase(product)
//            if result != nil {
//                withAnimation {
//                    os_log("\(self.t)购买回调，更新购买状态为 true")
//                    isPurchased = true
//                }
//            } else {
//                os_log("\(self.t)购买回调，结果为空，表示取消了")
//            }
//        } catch StoreError.failedVerification {
//            errorTitle = "App Store 验证失败"
//            isShowingError = true
//        } catch {
//            errorTitle = error.localizedDescription
//            isShowingError = true
//        }
//
//        purchasing = false
    }
}

// MARK: Event Handler

extension ProductCell {
    func onAppear() {
        let verbose = false
//        Task {
//            isPurchased = (try? await store.isPurchased(product)) ?? false
//
//            if verbose {
//                os_log("\(self.t)OnAppear 检查购买状态 -> \(product.displayName) -> \(isPurchased)")
//            }
//        }
    }
}

#Preview {
    RootView {
        BuyView()
    }
}
