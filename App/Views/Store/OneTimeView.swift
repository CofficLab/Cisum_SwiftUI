import SwiftUI
import StoreKit
import OSLog

struct OneTimeView: View {
    @EnvironmentObject var store: StoreManager
    
    private var products: [Product] {
        store.nonRenewables
    }
    
    var body: some View {
        Section("一次性订阅") {
            ForEach(products) { product in
                ProductCell(product: product, purchasingEnabled: store.purchasedSubscriptions.isEmpty)
            }
        }
    }
}

#Preview {
    RootView {
        BuyView()
    }
}
