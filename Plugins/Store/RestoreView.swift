import MagicCore

import OSLog
import StoreKit
import SwiftUI

struct RestoreView: View, SuperEvent, SuperLog, SuperThread {
    @EnvironmentObject var store: StoreProvider
    @EnvironmentObject var app: AppProvider
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @EnvironmentObject var m: MessageProvider

    @State private var subscriptions: [Product] = []
    @State private var refreshing = false
    @State private var error: Error? = nil

    nonisolated static let emoji = "🖥️"

    var body: some View {
        VStack {
            ZStack {
                Text("恢复购买").font(.title3)
            }

            Divider()

            Text("如果您之前在其他设备上购买过订阅，可以通过点击下方的\"恢复购买\"按钮来恢复您的订阅。\n\n请确保您使用的是购买时所用的 Apple ID 账号。\n\n恢复成功后，您将重新获得所有已购买的功能权限。")
                .padding()
                .multilineTextAlignment(.center)

            Button("恢复购买", action: {
                Task {
                    // This call displays a system prompt that asks users to authenticate with their App Store credentials.
                    // Call this function only in response to an explicit user action, such as tapping a button.
                    do {
                        os_log("\(self.t)恢复购买")
                        try await AppStore.sync()
                        os_log("\(self.t)恢复购买完成")
                        postRestore()
                    } catch {
                        m.error(error)
                    }
                }
            })
        }
    }
}

// MARK: Event Name

extension Notification.Name {
    static let Restored = Notification.Name("Restored")
}

// MARK: Event Emitter

extension RestoreView {
    func postRestore() {
        NotificationCenter.default.post(name: .Restored, object: nil)
    }
}

#Preview("Buy") {
    BuySetting()
        .environmentObject(StoreProvider())
        .frame(height: 800)
}
