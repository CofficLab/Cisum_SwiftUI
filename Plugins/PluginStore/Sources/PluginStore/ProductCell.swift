import CisumUI
import MagicKit
import OSLog
import StoreKit
import SwiftUI

struct ProductCell: View, SuperLog {
    @State var isPurchased: Bool = false
    @State var errorTitle = ""
    @State var isShowingError: Bool = false
    @State var purchasing = false
    @State var btnHovered: Bool = false
    @State var status: Product.SubscriptionInfo.Status?
    @State var current: Product?

    let product: ProductDTO
    let purchasingEnabled: Bool
    let showStatus: Bool

    var isCurrent: Bool {
        if let current = current {
            return current.id == product.id
        }

        return false
    }

    nonisolated static let emoji = "🖥️"

    init(product: ProductDTO, purchasingEnabled: Bool = true, showStatus: Bool = false) {
        self.product = product
        self.purchasingEnabled = purchasingEnabled
        self.showStatus = showStatus
    }

    var body: some View {
        HStack(spacing: 16) {
            // 产品详情
            VStack(alignment: .leading, spacing: 8) {
                // 产品名称
                Text(product.displayName)
                    .font(.body)
                    .fontWeight(.medium)

                // 价格信息
                if let subscription = product.subscription {
                    HStack(spacing: 4) {
                        Text(product.displayPrice)
                            .font(.title3)
                            .fontWeight(.bold)
                        Text("/")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(formatPeriodUnit(subscription.subscriptionPeriod))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Text(product.displayPrice)
                        .font(.title3)
                        .fontWeight(.bold)
                }

                // 试用期信息
                if let introOffer = product.subscription?.introductoryOffer {
                    HStack(spacing: 4) {
                        Image(systemName: "gift.fill")
                            .font(.caption2)
                        Text(formatIntroductoryOffer(introOffer))
                            .font(.caption)
                    }
                    .foregroundStyle(.blue)
                }
            }

            Spacer()

            // 购买按钮
            if purchasingEnabled {
                buyButton
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.regularMaterial)
                .stroke(borderColor, lineWidth: 1)
        )
        .cisumShadowSm()
        .alert(isPresented: $isShowingError, content: {
            Alert(title: Text(LocalizedStringKey(errorTitle), tableName: "Store", bundle: .module), message: nil, dismissButton: .default(Text("OK", tableName: "Store", bundle: .module)))
        })
    }

    // MARK: 子视图

    /// 边框颜色
    private var borderColor: Color {
        if isCurrent || isPurchased {
            return .green.opacity(0.3)
        }
        return .clear
    }

    // MARK: 购买按钮的提示词

    @ViewBuilder
    func subscribeButton(_ subscription: SubscriptionInfoDTO) -> some View {
        VStack(spacing: 2) {
            // 主要价格信息
            Text(product.displayPrice + "/" + formatPeriodUnit(subscription.subscriptionPeriod))
                .foregroundColor(.white)
                .bold()
        }
    }

    // MARK: 格式化周期单位

    private func formatPeriodUnit(_ period: StoreSubscriptionPeriodDTO) -> String {
        let plural = 1 < period.value
        switch period.unit {
        case "day":
            return plural ? String(localized: "\(period.value) days", table: "Store", bundle: .module) : String(localized: "day", table: "Store", bundle: .module)
        case "week":
            return plural ? String(localized: "\(period.value) weeks", table: "Store", bundle: .module) : String(localized: "week", table: "Store", bundle: .module)
        case "month":
            return plural ? String(localized: "\(period.value) months", table: "Store", bundle: .module) : String(localized: "month", table: "Store", bundle: .module)
        case "year":
            return plural ? String(localized: "\(period.value) years", table: "Store", bundle: .module) : String(localized: "year", table: "Store", bundle: .module)
        default:
            return String(localized: "period", table: "Store", bundle: .module)
        }
    }

    // MARK: 格式化试用期信息

    private func formatIntroductoryOffer(_ offer: IntroductoryOfferDTO) -> String {
        let periodText: String
        let plural = offer.subscriptionPeriod.value > 1

        switch offer.subscriptionPeriod.unit {
        case "day":
            periodText = plural ? String(localized: "\(offer.subscriptionPeriod.value) days", table: "Store", bundle: .module) : String(localized: "day", table: "Store", bundle: .module)
        case "week":
            periodText = plural ? String(localized: "\(offer.subscriptionPeriod.value) weeks", table: "Store", bundle: .module) : String(localized: "week", table: "Store", bundle: .module)
        case "month":
            periodText = plural ? String(localized: "\(offer.subscriptionPeriod.value) months", table: "Store", bundle: .module) : String(localized: "month", table: "Store", bundle: .module)
        case "year":
            periodText = plural ? String(localized: "\(offer.subscriptionPeriod.value) years", table: "Store", bundle: .module) : String(localized: "year", table: "Store", bundle: .module)
        default:
            periodText = String(localized: "period", table: "Store", bundle: .module)
        }

        switch offer.paymentMode {
        case "FreeTrial":
            return String(localized: "Free for \(periodText)", table: "Store", bundle: .module)
        case "PayAsYouGo":
            return String(localized: "\(offer.displayPrice) for first \(periodText)", table: "Store", bundle: .module)
        case "PayUpFront":
            return String(localized: "Pay \(offer.displayPrice) for first \(periodText)", table: "Store", bundle: .module)
        default:
            return String(localized: "Special offer for \(periodText)", table: "Store", bundle: .module)
        }
    }

    // MARK: 购买按钮

    var buyButton: some View {
        HStack(spacing: 6) {
            if purchasing {
                ProgressView()
                    .scaleEffect(0.8)
                Text("Processing...", tableName: "Store", bundle: .module)
            } else if isPurchased {
                Text(product.kind == .autoRenewable ? "Subscribed" : "Purchased", tableName: "Store", bundle: .module)
            } else {
                Text(product.kind == .autoRenewable ? "Subscribe" : "Purchase", tableName: "Store", bundle: .module)
            }
        }
        .fontWeight(.semibold)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.regularMaterial)
        .cisumHoverScale(105)
        .cisumRoundedMedium()
        .cisumShadowSm()
        .cisumButton(buy)
        .disabled(purchasing || isPurchased)
        .opacity(isPurchased ? 0.6 : 1.0)
        .onAppear(perform: onAppear)
    }

    // MARK: 去购买

    func buy() {
        purchasing = true
        Task {
            do {
                os_log("\(self.t)🏬 点击了购买按钮")

                let result = try await StoreService.purchase(product)
                if result != nil {
                    withAnimation {
                        os_log("\(self.t)🏬 购买回调，更新购买状态为 true")
                        isPurchased = true
                    }
                } else {
                    os_log("\(self.t)购买回调，结果为空，表示取消了")
                }
            } catch StoreError.failedVerification {
                errorTitle = "App Store verification failed"
                isShowingError = true
            } catch {
                errorTitle = error.localizedDescription
                isShowingError = true
            }

            purchasing = false
        }
    }
}

// MARK: Event Handler

extension ProductCell {
    func onAppear() {
        let verbose = false
        Task {
            // 检查购买状态
            let groups = try? await StoreService.fetchAllProducts()
            let purchasedLists = await StoreService.fetchPurchasedLists(
                cars: groups?.cars ?? [],
                subscriptions: groups?.subscriptions ?? [],
                nonRenewables: groups?.nonRenewables ?? []
            )

            switch product.kind {
            case .nonRenewable:
                isPurchased = purchasedLists.nonRenewables.contains { $0.id == product.id }
            case .nonConsumable:
                isPurchased = purchasedLists.cars.contains { $0.id == product.id }
            case .autoRenewable:
                isPurchased = purchasedLists.subscriptions.contains { $0.id == product.id }
            default:
                isPurchased = false
            }

            if verbose {
                os_log("\(self.t)OnAppear 检查购买状态 -> \(product.displayName) -> \(isPurchased)")
            }
        }
    }
}
