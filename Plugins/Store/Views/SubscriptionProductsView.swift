import SwiftUI

struct SubscriptionProductsView: View {
    @State private var subscriptions: [ProductDTO] = []

    var body: some View {
        productList(items: subscriptions)
            .task {
                await loadProducts()
            }
    }

    private func loadProducts() async {
        do {
            let groups = try await StoreService.fetchAllProducts()
            self.subscriptions = groups.subscriptions
        } catch {
            print("Failed to load products: \(error)")
        }
    }

    @ViewBuilder
    private func productList(items: [ProductDTO]) -> some View {
        if items.isEmpty {
            Text("暂无订阅商品").foregroundStyle(.secondary)
        } else {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 10) {
                    ForEach(items, id: \.id) { p in
                        ProductCell(product: p, purchasingEnabled: true, showStatus: true)
                        Divider()
                    }
                }
            }
        }
    }
}

// MARK: - Preview

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
