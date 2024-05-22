import SwiftUI

struct CarsView: View {
    @EnvironmentObject var store: StoreManager
    
    var body: some View {
        Section("小汽车") {
            ForEach(store.cars) { car in
                ProductCell(product: car)
            }
        }
    }
}
