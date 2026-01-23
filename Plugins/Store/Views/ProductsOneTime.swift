import SwiftUI

struct ProductsOfOneTime: View {
    @State private var cars: [ProductDTO] = []
    @State private var isLoading = false

    var body: some View {
        productList(items: cars)
            .task {
                await loadProducts()
            }
    }

    @ViewBuilder
    private func productList(items: [ProductDTO]) -> some View {
        if items.isEmpty {
            Text("暂无一次性购买商品").foregroundStyle(.secondary)
        } else {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 10) {
                    ForEach(items, id: \.id) { p in
                        ProductCell(product: p, purchasingEnabled: true, showStatus: false)
                        Divider()
                    }
                }
            }
        }
    }
    
    private func loadProducts() async {
        isLoading = true
        do {
            let groups = try await StoreService.fetchAllProducts()
            self.cars = groups.cars
        } catch {
            print("Failed to load products: \(error)")
        }
        isLoading = false
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
