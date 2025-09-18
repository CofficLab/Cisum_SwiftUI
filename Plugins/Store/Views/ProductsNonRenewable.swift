import SwiftUI

struct ProductsNonRenewable: View {
    @State private var nonRenewables: [ProductDTO] = []

    var body: some View {
        productList(items: nonRenewables)
            .task {
                await loadProducts()
            }
    }

    @ViewBuilder
    private func productList(items: [ProductDTO]) -> some View {
        if items.isEmpty {
            Text("暂无非续订商品").foregroundStyle(.secondary)
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
            self.nonRenewables = groups.nonRenewables
        } catch {
            print("Failed to load products: \(error)")
        }
    }
}


