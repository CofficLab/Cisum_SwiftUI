import CisumUIComponents
import Foundation
import OSLog
import StoreKit
import SwiftUI

enum StorePurchaseInfoLoadPolicy {
    static func shouldApplyResult(currentGeneration: Int, resultGeneration: Int) -> Bool {
        resultGeneration == currentGeneration
    }
}

public struct StoreSetting: View, SuperLog, SuperEvent {
    public nonisolated static let emoji = "💰"
    nonisolated static let purchaseActionLabel = String(
        localized: "In-App Purchase",
        bundle: .module
    )
    nonisolated static let restorePurchaseActionLabel = String(
        localized: "Restore Purchase",
        bundle: .module
    )

    @State private var showBuySheet = false
    @State private var showRestoreSheet = false
    @State private var purchaseInfo: PurchaseInfo = .none
    @State private var tierDisplayName: String = "Free"
    @State private var statusDescription: String = "Currently using free version"
    @State private var purchaseInfoGeneration = 0

    public init() {}

    public var body: some View {
        AppSettingSection(title: String(localized: "Subscription Information", bundle: .module), content: {
            // Current version
            AppSettingRow(title: String(localized: "Current Version", bundle: .module), description: String(localized: "Version you are using", bundle: .module), icon: "star.fill", content: {
                HStack {
                    Text(tierDisplayName)
                        .font(.footnote)
                }
            })

            // Subscription status
            AppSettingRow(title: String(localized: "Subscription Status", bundle: .module), description: statusDescription, icon: "info.circle", content: {
                HStack {
                    if purchaseInfo.isProOrHigher {
                        if purchaseInfo.isExpired {
                            Text("Expired", bundle: .module)
                                .font(.footnote)
                                .foregroundStyle(.red)
                        } else {
                            Text("Active", bundle: .module)
                                .font(.footnote)
                                .foregroundStyle(.green)
                        }
                    } else {
                        Text("Free", bundle: .module)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            })

            // Expiration date (if has subscription)
            if let expiresAt = purchaseInfo.expiresAt {
                AppSettingRow(title: String(localized: "Expiration Date", bundle: .module), description: String(localized: "Subscription expiration date", bundle: .module), icon: "calendar", content: {
                    HStack {
                        Text(expiresAt.fullDateTime)
                            .font(.footnote)
                    }
                })
            }

            // Purchase entry
            AppSettingRow(title: String(localized: "In-App Purchase", bundle: .module), description: String(localized: "Subscribe to Pro to unlock all features", bundle: .module), icon: "cart", content: {
                Image.cisumAppStore
                    .frame(width: 28)
                    .frame(height: 28)
                    .background(.regularMaterial, in: .circle)
                    .cisumShadowSm()
                    .cisumHoverScale(105)
                    .cisumButton({
                        showBuySheet = true
                    })
                    .accessibilityLabel(Self.purchaseActionLabel)
                    .help(Self.purchaseActionLabel)
            })

            // Restore purchase
            AppSettingRow(title: String(localized: "Restore Purchase", bundle: .module), description: String(localized: "Restore purchases made on other devices", bundle: .module), icon: "arrow.clockwise", content: {
                Image.cisumReset
                    .frame(width: 28)
                    .frame(height: 28)
                    .background(.regularMaterial, in: .circle)
                    .cisumShadowSm()
                    .cisumHoverScale(105)
                    .cisumButton({
                        showRestoreSheet = true
                    })
                    .accessibilityLabel(Self.restorePurchaseActionLabel)
                    .help(Self.restorePurchaseActionLabel)
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
        purchaseInfoGeneration += 1
        let generation = purchaseInfoGeneration

        Task {
            let info = await StoreService.getPurchaseInfo()
            await MainActor.run {
                guard StorePurchaseInfoLoadPolicy.shouldApplyResult(
                    currentGeneration: self.purchaseInfoGeneration,
                    resultGeneration: generation
                ) else { return }

                self.purchaseInfo = info
                self.tierDisplayName = StoreService.tierCached().displayName

                if info.isProOrHigher {
                    if info.isExpired {
                        self.statusDescription = String(localized: "Subscription has expired, please renew to continue using Pro features", bundle: .module)
                    } else {
                        self.statusDescription = String(localized: "Subscription is active, thank you for your support", bundle: .module)
                    }
                } else {
                    self.statusDescription = String(localized: "Currently using free version", bundle: .module)
                }
            }
        }
    }
}
