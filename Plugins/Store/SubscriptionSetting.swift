import MagicKit
import MagicUI
import OSLog
import StoreKit
import SwiftUI

struct SubscriptionSetting: View, SuperEvent, SuperLog, SuperThread {
    @EnvironmentObject var store: StoreProvider
    @EnvironmentObject var app: AppProvider
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    @State private var subscriptions: [Product] = []
    @State private var refreshing = false
    @State private var error: Error? = nil

    static let emoji = "🖥️"

    var body: some View {
        VStack {
            ZStack {
                Text("订阅专业版本").font(.title3)
                refreshButton
            }

            Divider()

            if refreshing == false && subscriptions.isEmpty {
                Text("🏃 暂无")
            } else {
                VStack {
                    ForEach(subscriptions) { product in
                        ProductCell(product: product)
                    }
                }
                .padding()
            }
        }.onAppear(perform: onAppear)
            .onReceive(NotificationCenter.default.publisher(for: .Restored), perform: onRestore)
    }

    private var refreshButton: some View {
        HStack {
            Spacer()
            ZStack {
                if refreshing {
                    ProgressView().scaleEffect(0.4)
                } else {
                    Button(action: onTapRefreshButton, label: {
                        Label("重试", systemImage: "arrow.clockwise")
                            .labelStyle(.iconOnly)
                    }).buttonStyle(.plain)
                }
            }.frame(width: 30, height: 10)
        }
    }

    // MARK: 获取可用的订阅

    private func getProducts(_ reason: String, verbose: Bool = true) {
        if verbose {
            os_log("\(self.t)GetProducts because of \(reason)")
        }

        refreshing = true

        Task {
            do {
                try await store.requestProducts(reason)

                self.subscriptions = store.subscriptions
            } catch {
                self.error = error
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                self.refreshing = false
            })
        }
    }
}

// MARK: Event Handler

extension SubscriptionSetting {
    func onAppear() {
        self.bg.async {
            Task {
                await getProducts("AllSubscription OnAppear")
            }
        }
    }

    func onTapRefreshButton() {
        self.bg.async {
            Task {
                await getProducts("点击了重试按钮")
            }
        }
    }

    func onRestore(_ notification: Notification) {
        self.bg.async {
            Task {
                await getProducts("恢复购买")
            }
        }
    }
}

#Preview("Buy") {
    BuySetting()
        .environmentObject(StoreProvider())
        .frame(height: 800)
}
