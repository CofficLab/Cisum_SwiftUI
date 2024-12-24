import OSLog
import StoreKit
import SwiftUI
import MagicKit

struct BtnBuy: View, SuperLog {
    static var emoji: String = "🎩"
    
    @EnvironmentObject var app: AppProvider
    
    @State var popover: Bool = false
    @State var proColor: Bool = true

    var isPro: Bool { true }

    var body: some View {
        Button(action: {
            popover.toggle()
        }) {
            Label(
                title: { Text("显示 DB") },
                icon: {
                    Image(systemName: "crown")
                        .foregroundStyle(proColor ? .yellow.opacity(0.5) : .gray)
                }
            )
            .controlSize(.large)
        }
        .onAppear {
            os_log("\(self.t)OnAppear, isPro = \(isPro)")
//            proColor = ProConfig.isPro
        }
        .onChange(of: isPro, {
            os_log("\(self.t)isPro 变成了 \(isPro)")
            self.proColor = isPro
        })
        .sheet(isPresented: $popover) {
            BuyView(onClose: {
                popover = false
            })
            //.frame(minWidth: 400, minHeight: 585)
            //.cornerRadius(10)
        }
    }
}

#Preview {
    AppPreview()
}
