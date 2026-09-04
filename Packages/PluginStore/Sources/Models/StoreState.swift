import Foundation
import CisumUIComponents
import OSLog
import StoreKit
import SwiftUI

final class StoreState: ObservableObject, SuperLog {
    nonisolated static let emoji = "💰"

    static let verbose = false

    // MARK: - Keys

    private enum Keys {
        static let purchase = "store.purchase"
        static let lastCheckedAt = "store.lastCheckedAt"
    }

    // MARK: - Public API

    static func cachedPurchaseInfo() -> PurchaseInfo {
        // Read the persisted structure directly from UserDefaults.
        let defaults = UserDefaults.standard
        if let data = defaults.data(forKey: Keys.purchase),
           let e = try? JSONDecoder().decode(PurchaseInfo.self, from: data) {
            return e
        }
        return .none
    }

    static func update(entitlement: PurchaseInfo) {
        let defaults = UserDefaults.standard
        if let data = try? JSONEncoder().encode(entitlement) {
            defaults.set(data, forKey: Keys.purchase)
        }
        defaults.set(Date().timeIntervalSince1970, forKey: Keys.lastCheckedAt)

        if self.verbose {
            os_log("\(self.t)🍋 Updated tier=\(entitlement.tier.rawValue), expiresAt=\(entitlement.expiresAtString)")
        }
    }

    static func clear() {
        update(entitlement: .none)
    }

    // Calibrate local state from current entitlements.
    static func calibrateFromCurrentEntitlements() async {
        var detectedTier: SubscriptionTier = .none
        var detectedExpire: Date?

        if self.verbose {
            os_log("\(self.t)🔄 Calibrating current entitlements")
        }

        for await result in StoreKit.Transaction.currentEntitlements {
            guard case let .verified(transaction) = result else {
                if self.verbose {
                    os_log("\(self.t)⚠️ Skipping unverified transaction")
                }
                continue
            }

            if self.verbose {
                os_log("\(self.t)📋 Checking transaction: \(transaction.productID), type: \(transaction.productType.rawValue)")
            }
            switch transaction.productType {
            case .autoRenewable:
                let t = StoreService.tier(for: transaction.productID)
                detectedTier = max(detectedTier, t)
                if verbose {
                    os_log("\(self.t)✅ Auto-renewable subscription: \(transaction.productID), tier: \(t.rawValue)")
                }

                // Record the latest expiration date.
                if let exp = transaction.expirationDate {
                    if let cur = detectedExpire {
                        detectedExpire = max(cur, exp)
                    } else {
                        detectedExpire = exp
                    }

                    if self.verbose {
                        os_log("\(self.t)⏰ Expiration date: \(exp.fullDateTime)")
                    }
                }
            case .nonRenewable:
                let t = StoreService.tier(for: transaction.productID)
                detectedTier = max(detectedTier, t)

                if verbose {
                    os_log("\(self.t)✅ Non-renewing subscription: \(transaction.productID), tier: \(t.rawValue)")
                }

                // For non-renewing subscriptions, check whether the entitlement is still valid.
                if let exp = transaction.expirationDate {
                    if exp > Date() {
                        // Still valid.
                        if let cur = detectedExpire {
                            detectedExpire = max(cur, exp)
                        } else {
                            detectedExpire = exp
                        }
                        if self.verbose {
                            os_log("\(self.t)⏰ Non-renewing subscription expiration date: \(exp.fullDateTime)")
                        }
                    } else {
                        if self.verbose {
                            os_log("\(self.t)⚠️ Non-renewing subscription expired: \(exp.fullDateTime)")
                        }
                    }
                }
            default:
                if self.verbose {
                    os_log("\(self.t)⏭️ Skipping other product type: \(transaction.productID)")
                }
                continue
            }
        }

        if self.verbose {
            os_log("\(self.t)🎯 Calibration result: detectedTier=\(detectedTier.rawValue), detectedExpire=\(detectedExpire?.description ?? "nil")")
        }

        // Update state on the main thread.
        await MainActor.run {
            update(entitlement: PurchaseInfo(tier: detectedTier, expiresAt: detectedExpire))
        }
    }
}
