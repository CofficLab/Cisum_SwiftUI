import SwiftUI

struct ProductsConsumable: View {
    @State private var fuel: [ProductDTO] = []

    var body: some View {
        productList(items: fuel)
            .task {
                await loadProducts()
            }
    }

    @ViewBuilder
    private func productList(items: [ProductDTO]) -> some View {
        if items.isEmpty {
            Text("暂无消耗品").foregroundStyle(.secondary)
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
        do {
            let groups = try await StoreService.fetchAllProducts()
            self.fuel = groups.fuel
        } catch {
            print("Failed to load products: \(error)")
        }
    }
}


