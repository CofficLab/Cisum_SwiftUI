import OSLog
import StoreKit
import SwiftUI

struct OneTimeView: View {
    @State private var products: [ProductDTO] = []
    @State private var purchasedSubscriptions: [ProductDTO] = []

    var body: some View {
        Section("一次性订阅") {
            ForEach(products) { product in
                ProductCell(product: product, purchasingEnabled: purchasedSubscriptions.isEmpty)
            }
        }
        .task {
            await loadProducts()
        }
    }

    private func loadProducts() async {
        do {
            let groups = try await StoreService.fetchAllProducts()
            self.products = groups.nonRenewables

            let purchasedLists = await StoreService.fetchPurchasedLists(
                cars: groups.cars,
                subscriptions: groups.subscriptions,
                nonRenewables: groups.nonRenewables
            )
            self.purchasedSubscriptions = purchasedLists.subscriptions
        } catch {
            print("Failed to load products: \(error)")
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
