import MagicAlert
import MagicKit
import OSLog
import StoreKit
import SwiftUI

struct RestoreView: View, SuperEvent, SuperLog, SuperThread {
    @EnvironmentObject var app: AppProvider
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @EnvironmentObject var m: MagicMessageProvider

    @State private var subscriptions: [Product] = []
    @State private var refreshing = false
    @State private var error: Error? = nil
    @State private var isRestoring = false

    nonisolated static let emoji = "🖥️"

    var body: some View {
        VStack(spacing: 16) {
            // 标题区域
            HStack(spacing: 12) {
                Image(systemName: "arrow.clockwise.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.blue)

                Text("恢复购买")
                    .font(.title3)
                    .fontWeight(.semibold)

                Spacer()
            }

            // 说明文字
            VStack(alignment: .leading, spacing: 12) {
                InfoRow(
                    icon: "iphone.and.arrow.forward",
                    title: "跨设备恢复",
                    description: "在其他设备上购买后，可在此恢复"
                )

                InfoRow(
                    icon: "person.circle",
                    title: "Apple ID 验证",
                    description: "请使用购买时的 Apple ID 账号"
                )

                InfoRow(
                    icon: "checkmark.circle",
                    title: "功能恢复",
                    description: "恢复成功后将获得所有已购买的功能"
                )
            }
            .padding(.vertical, 8)

            // 恢复购买按钮

            HStack(spacing: 8) {
                if isRestoring {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(0.8)
                    Text("正在恢复...")
                } else {
                    Image(systemName: "arrow.clockwise")
                        .fontWeight(.semibold)
                    Text("恢复购买")
                        .fontWeight(.semibold)
                }
            }
            .inCard()
            .inButtonWithAction {
                restorePurchase()
            }
            .disabled(isRestoring)
            #if os(macOS)
                .scaleEffect(isRestoring ? 0.98 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: isRestoring)
            #endif
        }
        .padding(20)
        .inCard()
        .infinite()
        .inScrollView()
    }

    // MARK: - Actions

    private func restorePurchase() {
        isRestoring = true
        Task {
            do {
                os_log("\(self.t)恢复购买")
                try await AppStore.sync()
                os_log("\(self.t)恢复购买完成")
                postRestore()
            } catch {
                m.error(error)
            }
            await MainActor.run {
                isRestoring = false
            }
        }
    }
}

// MARK: - Supporting Views

/// 信息行组件
struct InfoRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(.blue)
                .frame(width: 28, height: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: Event Emitter

extension RestoreView {
    func postRestore() {
        NotificationCenter.default.post(name: .Restored, object: nil)
    }
}

// MARK: - Preview

#Preview("Restore") {
    RestoreView()
        .inRootView()
        .frame(height: 800)
}

#Preview("Debug") {
    DebugView()
        .inRootView()
        .frame(height: 800)
}

#Preview("Purchase") {
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
