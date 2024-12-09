import Foundation
import StoreKit
import OSLog
import SwiftUI
import MagicKit

typealias Transaction = StoreKit.Transaction
typealias RenewalInfo = StoreKit.Product.SubscriptionInfo.RenewalInfo
typealias RenewalState = StoreKit.Product.SubscriptionInfo.RenewalState

public enum StoreError: Error, LocalizedError {
    case failedVerification
    case canNotGetProducts
    
    public var errorDescription: String? {
        switch self {
        case .failedVerification:
            "failedVerification"
        case .canNotGetProducts:
            "发生错误：无法获取产品"
        }
    }
}

//Define our app's subscription tiers by level of service, in ascending order.
public enum SubscriptionTier: Int, Comparable {
    case none = 0
    case pro = 1

    public static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

class StoreProvider: ObservableObject, SuperLog {
    static var label = "💰 Store::"
    
    let emoji = "👑"
    
    @Published private(set) var cars: [Product]
    @Published private(set) var fuel: [Product]
    @Published private(set) var subscriptions: [Product]
    @Published private(set) var nonRenewables: [Product]
    
    @Published private(set) var purchasedCars: [Product] = []
    @Published private(set) var purchasedNonRenewableSubscriptions: [Product] = []
    @Published private(set) var purchasedSubscriptions: [Product] = []
    @Published private(set) var subscriptionGroupStatus: RenewalState?
    
    @Published var currentSubscription: Product?
    @Published var status: Product.SubscriptionInfo.Status?
    
    var updateListenerTask: Task<Void, Error>? = nil

    private let productIdToEmoji: [String: String]

    init(verbose: Bool = false) {
        if verbose {
            os_log("\(Logger.isMain)\(Self.label)初始化")
        }
        
        productIdToEmoji = StoreProvider.loadProductIdToEmojiData()

        // 初始化产品列表，稍后填充
        cars = []
        fuel = []
        subscriptions = []
        nonRenewables = []

        //Start a transaction listener as close to app launch as possible so you don't miss any transactions.
        updateListenerTask = listenForTransactions("🐛 Store 初始化")

        Task(priority: .low) {
            // 从 AppStore获取产品列表
            try? await requestProducts("🐛 Store 初始化")
            // 更新用户已购产品列表
            await updatePurchased("🐛 Store 初始化")
            await updateSubscriptionStatus("🐛 Store 初始化")
        }
    }
    
    // MARK: 更新订阅组的状态
    func updateSubscriptionGroupStatus(_ state: RenewalState?, reason: String, verbose: Bool = false) {
        if verbose {
            os_log("\(self.t)更新订阅组的状态，因为 \(reason)")
        }
        
        self.subscriptionGroupStatus = state
        
        guard let s = self.subscriptionGroupStatus else {
            return os_log("\(self.t)订阅组状态: Nil")
        }

        switch s {
        case .expired:
            if verbose {
                os_log("\(self.t)订阅组状态: Expired")
            }
        case .inBillingRetryPeriod:
            if verbose {
                os_log("\(self.t)订阅组状态: InBillingRetryPeriod")
            }
        case .inGracePeriod:
            if verbose {
                os_log("\(self.t)订阅组状态: InGracePeriod")
            }
        case .revoked:
            if verbose {
                os_log("\(self.t)订阅组状态: Revoked")
            }
        case .subscribed:
            if verbose {
                os_log("\(self.t)订阅组状态: Subscribed")
            }
        default:
            if verbose {
                os_log(.error, "\(self.t)订阅组状态: 未知")
            }
        }
    }
    
    // MARK: 更新当前订阅的产品
    func updateSubscription(_ sub: Product?, verbose: Bool = false) {
        if verbose {
            os_log("\(self.t)StoreManger 更新订阅计划为 \(sub?.displayName ?? "-")")
        }
        
        self.currentSubscription = sub
    }
    
    // MARK: 更新当前订阅的产品的状态
    func updateStatus(_ status: Product.SubscriptionInfo.Status?, verbose: Bool = false) {
        if verbose {
            os_log("\(self.t)StoreManger 更新订阅状态")
        }
        
        self.status = status
    }

    // MARK: 更新已购列表
    
    @MainActor func updatePurchased(_ reason: String, verbose: Bool = false) async {
        if verbose {
            os_log("\(self.t)更新已购列表，因为 -> \(reason)")
        }
        
        var purchasedCars: [Product] = []
        var purchasedSubscriptions: [Product] = []
        var purchasedNonRenewableSubscriptions: [Product] = []

        //Iterate through all of the user's purchased products.
        for await result in Transaction.currentEntitlements {
            do {
                //Check whether the transaction is verified. If it isn’t, catch `failedVerification` error.
                let transaction = try checkVerified(result)

                //Check the `productType` of the transaction and get the corresponding product from the store.
                switch transaction.productType {
                case .nonConsumable:
                    os_log("\(Logger.isMain) 🚩 💰 更新购买状态 -> nonConsumable")
                    if let car = cars.first(where: { $0.id == transaction.productID }) {
                        os_log("\(Logger.isMain) 🚩 💰 更新购买状态 -> 已购车: \(car.displayName)")
                        purchasedCars.append(car)
                    }
                case .nonRenewable:
                    os_log("\(Logger.isMain) 🚩 💰 更新购买状态 -> nonRenewable")
                    if let nonRenewable = nonRenewables.first(where: { $0.id == transaction.productID }),
                       transaction.productID == "nonRenewing.standard" {
                        //Non-renewing subscriptions have no inherent expiration date, so they're always
                        //contained in `Transaction.currentEntitlements` after the user purchases them.
                        //This app defines this non-renewing subscription's expiration date to be one year after purchase.
                        //If the current date is within one year of the `purchaseDate`, the user is still entitled to this
                        //product.
                        let currentDate = Date()
                        let expirationDate = Calendar(identifier: .gregorian).date(byAdding: DateComponents(year: 1), to: transaction.purchaseDate)!

                        if currentDate < expirationDate {
                            os_log("\(Logger.isMain) 🚩💰 更新购买状态 -> 已购: \(nonRenewable.displayName)")
                            purchasedNonRenewableSubscriptions.append(nonRenewable)
                        }
                    }
                case .autoRenewable:
                    if let subscription = subscriptions.first(where: { $0.id == transaction.productID }) {
                        os_log("\(self.t)更新已购列表 -> 已购: \(subscription.displayName)")
                        
                        purchasedSubscriptions.append(subscription)
                    }
                default:
                    Logger.app.error("\(Logger.isMain) 💰 更新已购列表，产品类型未知")
                    break
                }
            } catch let error {
                Logger.app.error("\(Logger.isMain) 💰 更新已购列表出错 -> \(error.localizedDescription)")
            }
        }

        //Update the store information with the purchased products.
        self.purchasedCars = purchasedCars
        self.purchasedNonRenewableSubscriptions = purchasedNonRenewableSubscriptions

        //Update the store information with auto-renewable subscription products.
        self.purchasedSubscriptions = purchasedSubscriptions

        //Check the `subscriptionGroupStatus` to learn the auto-renewable subscription state to determine whether the customer
        //is new (never subscribed), active, or inactive (expired subscription). This app has only one subscription
        //group, so products in the subscriptions array all belong to the same group. The statuses that
        //`product.subscription.status` returns apply to the entire subscription group.
        // MARK: 更新订阅组状态
        let subscriptionGroupStatus = try? await subscriptions.first?.subscription?.status.first?.state
        updateSubscriptionGroupStatus(subscriptionGroupStatus, reason: "\(reason) -> 🐛 更新已购列表")
    }

    deinit {
        updateListenerTask?.cancel()
    }
    
    static func loadProductIdToEmojiData() -> [String: String] {
        guard let path = Bundle.main.path(forResource: "Products", ofType: "plist"),
              let plist = FileManager.default.contents(atPath: path),
              let data = try? PropertyListSerialization.propertyList(from: plist, format: nil) as? [String: String] else {
            return [:]
        }
        return data
    }

    func listenForTransactions(_ reason: String, verbose: Bool = false) -> Task<Void, Error> {
        if verbose {
            os_log("\(self.t)ListenForTransactions，因为 -> \(reason)")
        }
        
        return Task.detached {
            //Iterate through any transactions that don't come from a direct call to `purchase()`.
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)

                    //Deliver products to the user.
                    await self.updatePurchased("\(reason) -> 🐛 ListenForTransactions")

                    //Always finish a transaction.
                    await transaction.finish()
                } catch {
                    //StoreKit has a transaction that fails verification. Don't deliver content to the user.
                    print("Transaction failed verification")
                }
            }
        }
    }

    // 获取产品列表有缓存
    // 因为联网获取后，再断网，一段时间内仍然能得到列表
    // 出现过的情况：
    //  断网，报错
    //  联网得到2个产品，断网，依然得到两个产品
    //  联网得到2个产品，断网，依然得到两个产品，再等等，不报错，得到0个产品
    @MainActor
    func requestProducts(_ reason: String, verbose: Bool = false) async throws {
        if verbose {
            os_log("\(self.t)请求 App Store 获取产品列表，并存储到 @Published，因为 -> \(reason)")
        }
        
        do {
            //Request products from the App Store using the identifiers that the Products.plist file defines.
            let storeProducts = try await Product.products(for: productIdToEmoji.keys)

            var newCars: [Product] = []
            var newSubscriptions: [Product] = []
            var newNonRenewables: [Product] = []
            var newFuel: [Product] = []

            if verbose {
                os_log("\(self.t)将从 App Store 获取的产品列表归类，个数 -> \(storeProducts.count)")
            }
            
            //Filter the products into categories based on their type.
            for product in storeProducts {
                if verbose {
                    os_log("\(self.t)将从 App Store 获取的产品列表归类 -> \(product.displayName)")
                }
                
                switch product.type {
                case .consumable:
                    newFuel.append(product)
                case .nonConsumable:
                    newCars.append(product)
                case .autoRenewable:
                    newSubscriptions.append(product)
                case .nonRenewable:
                    newNonRenewables.append(product)
                default:
                    //Ignore this product.
                    print("Unknown product")
                }
            }

            //Sort each product category by price, lowest to highest, to update the store.
            cars = sortByPrice(newCars)
            subscriptions = sortByPrice(newSubscriptions)
            nonRenewables = sortByPrice(newNonRenewables)
            fuel = sortByPrice(newFuel)
        } catch let error {
            os_log(.error, "\(self.t)请求 App Store 获取产品列表出错 -> \(error.localizedDescription)")
            
            throw error
        }
    }
    
    // MARK: 购买与支付

    func purchase(_ product: Product) async throws -> Transaction? {
        os_log("\(self.t)去支付")
        
        #if os(visionOS)
        return nil
        #else
        //Begin purchasing the `Product` the user selects.
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            os_log("\(self.t)支付成功，验证")
            //Check whether the transaction is verified. If it isn't,
            //this function rethrows the verification error.
            let transaction = try checkVerified(verification)

            os_log("\(self.t)支付成功，验证成功")
            //The transaction is verified. Deliver content to the user.
            await updatePurchased("支付并验证成功")

            //Always finish a transaction.
            await transaction.finish()

            return transaction
        case .userCancelled, .pending:
            os_log("\(self.t)取消或pending")
            return nil
        default:
            os_log("\(self.t)支付结果 \(String(describing: result))")
            return nil
        }
        #endif
    }

    func isPurchased(_ product: Product) async throws -> Bool {
        //Determine whether the user purchases a given product.
        switch product.type {
        case .nonRenewable:
            return purchasedNonRenewableSubscriptions.contains(product)
        case .nonConsumable:
            return purchasedCars.contains(product)
        case .autoRenewable:
            return purchasedSubscriptions.contains(product)
        default:
            return false
        }
    }

    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        //Check whether the JWS passes StoreKit verification.
        switch result {
        case .unverified:
            //StoreKit parses the JWS, but it fails verification.
            throw StoreError.failedVerification
        case .verified(let safe):
            //The result is verified. Return the unwrapped value.
            return safe
        }
    }

    func emoji(for productId: String) -> String {
        return productIdToEmoji[productId]!
    }

    func sortByPrice(_ products: [Product]) -> [Product] {
        products.sorted(by: { return $0.price < $1.price })
    }

    //Get a subscription's level of service using the product ID.
    func tier(for productId: String) -> SubscriptionTier {
        // 目前，只有一个pro版本
        return .pro
    }
    
    // MAKR: 更新订阅状态
    
    @MainActor
    func updateSubscriptionStatus(_ reason: String, _ completion: ((Error?) -> Void)? = nil, verbose: Bool = false) async {
        if verbose {
            os_log("\(self.t)StoreManger 检查订阅状态，因为 -> \(reason)")
        }
        
        guard subscriptions.count > 0 else {
            if let c = completion {
                c(StoreError.canNotGetProducts)
            }
            
            return Logger.app.warning("\(self.t)StoreManger 检查订阅状态，订阅计划为空，可能之前的步骤获取失败，停止")
        }
        
        // 订阅组可以多个，但一般设置一个
        //  1. 专业版订阅计划
        //    1.1 按年
        //    1.2 按月
        //  2. xxx 订阅计划
        do {
            // This app has only one subscription group, so products in the subscriptions
            // array all belong to the same group. The statuses that
            // `product.subscription.status` returns apply to the entire subscription group.
            guard let product = subscriptions.first,
                  let statuses = try await product.subscription?.status else {
                return
            }

            var highestStatus: Product.SubscriptionInfo.Status?
            var highestProduct: Product?
            
            if verbose {
                os_log("\(self.t)StoreManger 检查订阅状态，statuses.count -> \(statuses.count)")
            }

            // Iterate through `statuses` for this subscription group and find
            // the `Status` with the highest level of service that isn't
            // in an expired or revoked state. For example, a customer may be subscribed to the
            // same product with different levels of service through Family Sharing.
            for status in statuses {
                switch status.state {
                case .expired, .revoked:
                    if verbose {
                        os_log("\(self.t)检查订阅状态 -> 超时或被撤销")
                    }
                    
                    continue
                default:
                    let renewalInfo = try checkVerified(status.renewalInfo)

                    // Find the first subscription product that matches the subscription status renewal info by comparing the product IDs.
                    guard let newSubscription = subscriptions.first(where: { $0.id == renewalInfo.currentProductID }) else {
                        continue
                    }

                    guard let currentProduct = highestProduct else {
                        highestStatus = status
                        highestProduct = newSubscription
                        continue
                    }

                    let highestTier = tier(for: currentProduct.id)
                    let newTier = tier(for: renewalInfo.currentProductID)

                    if newTier > highestTier {
                        highestStatus = status
                        highestProduct = newSubscription
                    }
                }
            }

            updateStatus(highestStatus)
            updateSubscription(highestProduct)
            
            if let c = completion {
                c(nil)
            }
        } catch {
            Logger.app.error("\(Logger.isMain) 💰 StoreManger 检查订阅状态，出错 -> \(error.localizedDescription)")
            if let c = completion {
                c(error)
            }
        }
    }
    
    // MARK: 获取Pro版本失效时间
    
    func getExpirationDate() -> Date {
        os_log("\(Logger.isMain) 💰 StoreManger 获取失效时间")
        
        guard let status = status else {
            os_log("\(Logger.isMain) 💰 StoreManger 获取失效时间 -> 无状态，返回很早时间")
            return Date.distantPast
        }
        
        guard case let .verified(renewalInfo) = status.renewalInfo,
              case let .verified(transaction) = status.transaction else {
            Logger.app.error("\(Logger.isMain) 💰 getExpirationDate 出错 -> App Store 无法验证")
            return Date.distantPast
        }
        
        switch status.state {
        case .subscribed:
            print("💰 获取状态 -> subscribed")
            if let expirationDate = transaction.expirationDate {
                os_log("\(Logger.isMain) 💰 StoreManger 获取失效时间 -> 已订阅 -> \(expirationDate)")
                return expirationDate
            } else {
                Logger.app.error("\(Logger.isMain) 💰 StoreManger 获取失效时间 -> 已订阅但无 expirationDate")
                return Date.distantPast
            }
        case .expired:
            print("💰 expired")
            if let expirationDate = transaction.expirationDate {
                return expirationDate
            }
        case .revoked:
            print("💰 revoked")
            return Date.distantPast
        case .inGracePeriod:
            print("💰 inGracePeriod")
            if let untilDate = renewalInfo.gracePeriodExpirationDate {
                return untilDate
            } else {
                return Date.distantPast
            }
        case .inBillingRetryPeriod:
            print("💰 inBillingRetryPeriod")
            return Date.now.addingTimeInterval(24 * 3600)
        default:
            print("💰 default")
            return Date.distantPast
        }
        
        return Date.distantPast
    }
}

#Preview {
    RootView {
        BuyView()
    }
    .frame(height: 800)
}
