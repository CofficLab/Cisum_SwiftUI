import SwiftUI
import StoreKit
import OSLog

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

#Preview("Buy") {
    PurchaseView()
        .inRootView()
        .frame(height: 800)
}

#Preview("APP") {
    ContentView()
        .inRootView()
        .frame(width: 700)
        .frame(height: 800)
}
