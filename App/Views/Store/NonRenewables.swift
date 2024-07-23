import OSLog
import StoreKit
import SwiftUI

struct NonRenewables: View {
    @EnvironmentObject var store: StoreProvider
    @EnvironmentObject var app: AppProvider

    @State private var nonRenewables: [Product] = []
    @State private var refreshing = false
    @State private var error: Error? = nil

    var body: some View {
        GroupBox {
            VStack {
                ZStack {
                    Text("一次性产品").font(.title3)
                    refreshButton
                }

                Divider()

                if refreshing == false && nonRenewables.isEmpty {
                    Text("☹️ 暂不能从App Store获取产品列表")
                } else {
                    VStack {
                        ForEach(nonRenewables) { product in
                            ProductCell(product: product)
                        }
                    }
                    .padding()
                }
            }
        }
        .background(BackgroundView.type2.opacity(0.1))
        .onAppear {
            getProducts("AllSubscription OnAppear")
        }
    }

    private var refreshButton: some View {
        HStack {
            Spacer()
            ZStack {
                if refreshing {
                    ProgressView().scaleEffect(0.4)
                } else {
                    Button(action: {
                        
                        getProducts("点击了重试按钮")
                    }, label: {
                        Label("重试", systemImage: "arrow.clockwise")
                            .labelStyle(.iconOnly)
                    }).buttonStyle(.plain)
                }
            }.frame(width: 30, height: 10)
        }
    }

    // MARK: 获取可用的订阅

    private func getProducts(_ reason: String) {
        refreshing = true

        Task {
            await store.requestProducts(reason, { error in
                self.error = error
                self.nonRenewables = store.nonRenewables
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                    refreshing = false
                })
            })
        }
    }
}

#Preview {
    BootView {
        BuyView()
    }.frame(height: 400)
}
