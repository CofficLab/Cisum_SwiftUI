import MagicKit
import OSLog
import StoreKit
import SwiftUI

struct ProductsSubscription: View, SuperEvent, SuperLog, SuperThread {
    @EnvironmentObject var app: AppProvider
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    @State private var subscriptionGroups: [SubscriptionGroupDTO] = []
    @State private var refreshing = false
    @State private var error: Error? = nil

    nonisolated static let emoji = "🖥️"

    var body: some View {
        Group {
            if !refreshing && subscriptionGroups.isEmpty {
                emptyStateView
            } else {
                LazyVStack(spacing: 20) {
                    ForEach(subscriptionGroups, id: \.id) { group in
                        VStack(alignment: .leading, spacing: 16) {
                            // 订阅组头部
                            HStack(alignment: .center, spacing: 12) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(group.name)
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .if(group.name.isNotEmpty)

                                    Text("\(group.subscriptions.count) 个订阅选项")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                // 订阅组ID标签
                                Text("ID: \(group.id)")
                                    .font(.system(.caption2, design: .monospaced))
                                    .foregroundStyle(.secondary)
                            }

                            // 订阅产品列表
                            VStack(spacing: 12) {
                                ForEach(group.subscriptions, id: \.id) { subscription in
                                    ProductCell(product: subscription)
                                }
                            }
                        }
                        .padding()
                        .background(.background.opacity(0.4))
                        .roundedMedium()
                        .shadowSm()
                    }
                }
                .inScrollView()
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
            Text("暂无订阅选项")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: 获取可用的订阅

    private func getProducts(_ reason: String, verbose: Bool = true) {
        if verbose {
            os_log("\(self.t)GetProducts because of \(reason)")
        }

        refreshing = true

        Task {
            do {
                let groups = try await StoreService.fetchAllProducts()
                self.subscriptionGroups = groups.subscriptionGroups
            } catch {
                self.error = error
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                self.refreshing = false
            })
        }
    }
}

// MARK: Event Handler

extension ProductsSubscription {
    func onAppear() {
        self.bg.async {
            Task {
                await getProducts("AllSubscription OnAppear")
            }
        }
    }

    func onRestore(_ notification: Notification) {
        self.bg.async {
            Task {
                await getProducts("恢复购买")
            }
        }
    }
}

// MARK: - Preview

#Preview("PurchaseView - All") {
    PurchaseView()
        .inRootView()
        .frame(height: 800)
}

#Preview("PurchaseView - Subscription Only") {
    PurchaseView(
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

#Preview("Debug") {
    DebugView()
        .inRootView()
        .frame(height: 800)
}

#Preview("Buy") {
    PurchaseView()
        .inRootView()
        .frame(height: 800)
}

#if os(macOS)
    #Preview("App - Large") {
        ContentView()
            .inRootView()
            .frame(width: 600, height: 1000)
    }

    #Preview("App - Small") {
        ContentView()
            .inRootView()
            .frame(width: 500, height: 800)
    }
#endif

#if os(iOS)
    #Preview("iPhone") {
        ContentView()
            .inRootView()
    }
#endif
