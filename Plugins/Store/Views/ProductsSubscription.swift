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
        ScrollView {
            VStack {
                if refreshing == false && subscriptionGroups.isEmpty {
                    Text("🏃 暂无")
                } else {
                    VStack(spacing: 16) {
                        ForEach(subscriptionGroups, id: \.id) { group in
                            subscriptionGroupView(group: group)
                        }
                    }
                    .padding()
                }
            }.onAppear(perform: onAppear)
                .onRestored(perform: onRestore)
        }
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
    
    @ViewBuilder
    private func subscriptionGroupView(group: SubscriptionGroupDTO) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // 订阅组标题
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(group.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("\(group.subscriptions.count) 个订阅选项")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Text("ID: \(group.id)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(4)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
            
            // 订阅组下的订阅产品
            VStack(spacing: 8) {
                ForEach(group.subscriptions, id: \.id) { subscription in
                    ProductCell(product: subscription)
                }
            }
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
    PurchaseView(showCloseButton: false)
        .inRootView()
        .frame(height: 800)
}

#Preview("PurchaseView - Subscription Only") {
    PurchaseView(showCloseButton: false,
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
