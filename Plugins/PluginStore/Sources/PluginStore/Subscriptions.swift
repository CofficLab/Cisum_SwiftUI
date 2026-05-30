import CisumUI
import MagicKit
import OSLog
import StoreKit
import SwiftUI

enum StoreProductListPresentation {
    enum State: Equatable {
        case loading
        case error
        case empty
        case content
    }

    static func state(isRefreshing: Bool, hasGroups: Bool, hasError: Bool) -> State {
        if isRefreshing, !hasGroups {
            return .loading
        }

        if hasError, !hasGroups {
            return .error
        }

        if !hasGroups {
            return .empty
        }

        return .content
    }
}

struct ProductsSubscription: View, SuperEvent, SuperLog, SuperThread {
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    @State private var subscriptionGroups: [SubscriptionGroupDTO] = []
    @State private var purchasedProductIDs = Set<String>()
    @State private var refreshing = false
    @State private var error: Error? = nil

    nonisolated static let emoji = "🖥️"
    nonisolated static var verbose: Bool { false }

    /// 是否展示头部
    var showHeader: Bool = true

    init(showHeader: Bool = true) {
        self.showHeader = showHeader
    }

    var body: some View {
        Group {
            switch StoreProductListPresentation.state(
                isRefreshing: refreshing,
                hasGroups: !subscriptionGroups.isEmpty,
                hasError: error != nil
            ) {
            case .loading:
                loadingStateView
            case .error:
                errorStateView
            case .empty:
                emptyStateView
            case .content:
                LazyVStack(spacing: 20) {
                    ForEach(subscriptionGroups, id: \.id) { group in
                        VStack(alignment: .leading, spacing: 16) {
                            // 订阅组头部
                            if showHeader {
                                HStack(alignment: .center, spacing: 12) {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(group.name)
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                            .cisumIf(group.name.isNotEmpty)

                                        Text("\(group.subscriptions.count) 个订阅选项", tableName: "Store", bundle: .module)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }

                                    Spacer()

                                    // 订阅组ID标签
                                    Text("ID: \(group.id)")
                                        .font(.system(.caption2, design: .monospaced))
                                        .foregroundStyle(.secondary)
                                }
                            }

                            // 订阅产品列表
                            VStack(spacing: 12) {
                                ForEach(group.subscriptions, id: \.id) { subscription in
                                    ProductCell(
                                        product: subscription,
                                        initiallyPurchased: purchasedProductIDs.contains(subscription.id)
                                    )
                                }
                            }
                        }
                    }
                }
                .cisumScrollView()
            }
        }
        .onAppear(perform: onAppear)
        .onRestored(perform: onRestore)
    }

    // MARK: - 子视图

    /// 空状态视图
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "cart.circle")
                .font(.system(size: 64))
                .foregroundStyle(.tertiary)
            Text("暂无订阅选项", tableName: "Store", bundle: .module)
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var loadingStateView: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Loading subscription options...", tableName: "Store", bundle: .module)
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var errorStateView: some View {
        VStack(spacing: 16) {
            AppStatusBanner(
                kind: .error,
                title: String(localized: "Cannot load subscription options", table: "Store", bundle: .module),
                message: error?.localizedDescription ?? String(localized: "Please check your network and try again.", table: "Store", bundle: .module)
            )

            AppSheetActionButton(
                title: String(localized: "Try Again", table: "Store", bundle: .module),
                systemImage: "arrow.clockwise"
            ) {
                getProducts("Retry after load failure")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 16)
    }

    // MARK: 获取可用的订阅

    private func getProducts(_ reason: String) {
        if Self.verbose {
            os_log("\(self.t)🚀 (\(reason)) GetProducts")
        }

        refreshing = true

        Task {
            do {
                let groups = try await StoreService.fetchAllProducts()
                let purchasedLists = await StoreService.fetchPurchasedLists(
                    cars: groups.cars,
                    subscriptions: groups.subscriptions,
                    nonRenewables: groups.nonRenewables
                )
                let purchasedIDs = Set(
                    (purchasedLists.cars + purchasedLists.subscriptions + purchasedLists.nonRenewables).map(\.id)
                )
                await MainActor.run {
                    self.subscriptionGroups = groups.subscriptionGroups
                    self.purchasedProductIDs = purchasedIDs
                    self.error = nil
                    self.refreshing = false
                }
            } catch {
                await MainActor.run {
                    self.error = error
                    self.refreshing = false
                }
            }
        }
    }
}

// MARK: Event Handler

extension ProductsSubscription {
    func onAppear() {
        getProducts("AllSubscription OnAppear")
    }

    func onRestore(_ notification: Notification) {
        getProducts("恢复购买")
    }
}
