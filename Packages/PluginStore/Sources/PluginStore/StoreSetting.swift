import CisumUI
import Foundation
import MagicAlert
import MagicKit
import OSLog
import StoreKit
import SwiftUI

public struct StoreSetting: View, SuperLog, SuperEvent {
    public nonisolated static let emoji = "💰"

    @State private var showBuySheet = false
    @State private var showRestoreSheet = false
    @State private var purchaseInfo: PurchaseInfo = .none
    @State private var tierDisplayName: String = "Free"
    @State private var statusDescription: String = "Currently using free version"

    public init() {}

    public var body: some View {
        CisumUI.MagicSettingSection(title: String(localized: "Subscription Information", table: "Store", bundle: .module), content: {
            // Current version
            CisumUI.MagicSettingRow(title: String(localized: "Current Version", table: "Store", bundle: .module), description: String(localized: "Version you are using", table: "Store", bundle: .module), icon: "star.fill", content: {
                HStack {
                    Text(tierDisplayName)
                        .font(.footnote)
                }
            })

            // Subscription status
            CisumUI.MagicSettingRow(title: String(localized: "Subscription Status", table: "Store", bundle: .module), description: statusDescription, icon: "info.circle", content: {
                HStack {
                    if purchaseInfo.isProOrHigher {
                        if purchaseInfo.isExpired {
                            Text("Expired", tableName: "Store")
                                .font(.footnote)
                                .foregroundStyle(.red)
                        } else {
                            Text("Active", tableName: "Store")
                                .font(.footnote)
                                .foregroundStyle(.green)
                        }
                    } else {
                        Text("Free", tableName: "Store")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            })

            // Expiration date (if has subscription)
            if let expiresAt = purchaseInfo.expiresAt {
                CisumUI.MagicSettingRow(title: String(localized: "Expiration Date", table: "Store", bundle: .module), description: String(localized: "Subscription expiration date", table: "Store", bundle: .module), icon: "calendar", content: {
                    HStack {
                        Text(expiresAt.fullDateTime)
                            .font(.footnote)
                    }
                })
            }

            // Purchase entry
            CisumUI.MagicSettingRow(title: String(localized: "In-App Purchase", table: "Store", bundle: .module), description: String(localized: "Subscribe to Pro to unlock all features", table: "Store", bundle: .module), icon: "cart", content: {
                Image.cisumAppStore
                    .frame(width: 28)
                    .frame(height: 28)
                    .background(.regularMaterial, in: .circle)
                    .cisumShadowSm()
                    .cisumHoverScale(105)
                    .cisumButton({
                        showBuySheet = true
                    })
            })

            // Restore purchase
            CisumUI.MagicSettingRow(title: String(localized: "Restore Purchase", table: "Store", bundle: .module), description: String(localized: "Restore purchases made on other devices", table: "Store", bundle: .module), icon: "arrow.clockwise", content: {
                Image.cisumReset
                    .frame(width: 28)
                    .frame(height: 28)
                    .background(.regularMaterial, in: .circle)
                    .cisumShadowSm()
                    .cisumHoverScale(105)
                    .cisumButton({
                        showRestoreSheet = true
                    })
            })
        })
        .sheet(isPresented: $showBuySheet) {
            PurchaseView()
        }
        .sheet(isPresented: $showRestoreSheet) {
            RestoreView()
        }
        .task {
            self.updatePurchaseInfo()
        }
        .onReceive(NotificationCenter.default.publisher(for: .storeTransactionUpdated)) { _ in
            self.updatePurchaseInfo()
        }
        .onReceive(NotificationCenter.default.publisher(for: .Restored)) { _ in
            self.updatePurchaseInfo()
        }
    }
}

// MARK: - Actions

extension StoreSetting {
    private func updatePurchaseInfo() {
        Task {
            let info = await StoreService.getPurchaseInfo()
            await MainActor.run {
                self.purchaseInfo = info
                self.tierDisplayName = StoreService.tierCached().displayName

                if info.isProOrHigher {
                    if info.isExpired {
                        self.statusDescription = String(localized: "Subscription has expired, please renew to continue using Pro features", table: "Store", bundle: .module)
                    } else {
                        self.statusDescription = String(localized: "Subscription is active, thank you for your support", table: "Store", bundle: .module)
                    }
                } else {
                    self.statusDescription = String(localized: "Currently using free version", table: "Store", bundle: .module)
                }
            }
        }
    }
}
