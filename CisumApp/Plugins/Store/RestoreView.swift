import CisumUI
import MagicAlert
import OSLog
import StoreKit
import SwiftUI

struct RestoreView: View, SuperEvent, SuperLog, SuperThread {
    @EnvironmentObject var app: AppProvider
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Environment(\.dismiss) private var dismiss

    @State private var subscriptions: [Product] = []
    @State private var refreshing = false
    @State private var error: Error? = nil
    @State private var restoreState: RestoreState = .idle

    nonisolated static let emoji = "🖥️"
    nonisolated static let verbose = true

    init() {}

    var body: some View {
        SheetContainer {
            VStack(spacing: 16) {
                // 说明文字
                AppSheetPanel {
                    VStack(spacing: 16) {
                    AppSheetIconHeader(systemImage: "icloud.and.arrow.down.fill", title: "Restore Purchase", tint: .blue)
                    VStack(alignment: .leading, spacing: 12) {
                        AppInfoRow(
                            icon: "iphone.and.arrow.forward",
                            title: String(localized: "Cross-Device Restore", table: "Store"),
                            description: String(localized: "Restore purchases made on other devices", table: "Store"),
                            tint: .blue
                        )

                        AppInfoRow(
                            icon: "person.circle",
                            title: String(localized: "Apple ID Verification", table: "Store"),
                            description: String(localized: "Use the same Apple ID used for purchase", table: "Store"),
                            tint: .blue
                        )

                        AppInfoRow(
                            icon: "checkmark.circle",
                            title: String(localized: "Feature Restore", table: "Store"),
                            description: String(localized: "Get all purchased features after successful restore", table: "Store"),
                            tint: .blue
                        )
                    }
                    .padding(.vertical, 8)
                    }
                }

                // Status banner area
                if restoreState != .idle {
                    statusBanner
                }

                // Button area
                successButtons
                    .cisumIf(self.restoreState == .success)

                restoreButton
                    .cisumIf(self.restoreState == .failed || self.restoreState == .idle)
            }.cisumVStackCenter()
        }
    }

    // MARK: - View

    @ViewBuilder
    private var statusBanner: some View {
        switch restoreState {
        case .idle:
            EmptyView()
        case .restoring:
            AppStatusBanner(kind: .loading, title: "Restoring Purchase", message: "Please wait, verifying your purchase records...")
        case .success:
            AppStatusBanner(kind: .success, title: "Restore Successful", message: "Successfully restored your purchase records, all features unlocked")
        case .failed:
            AppStatusBanner(kind: .error, title: "Restore Failed", message: error?.localizedDescription ?? String(localized: "An error occurred while restoring, please try again later", table: "Store"))
        }
    }

    @ViewBuilder
    private var restoreButton: some View {
        AppSheetActionButton(
            restoreState == .failed ? "Retry Restore" : "Restore Purchase",
            systemImage: "arrow.clockwise"
        ) {
            restorePurchase()
        }
        .disabled(restoreState == .restoring)
    }

    @ViewBuilder
    private var successButtons: some View {
        HStack(spacing: 12) {
            AppSheetActionButton("Done", systemImage: "checkmark.circle.fill") {
                dismiss()
            }

            AppSheetActionButton("Try Again", systemImage: "arrow.clockwise") {
                restoreState = .idle
                restorePurchase()
            }
        }
    }

    // MARK: - Actions

    private func restorePurchase() {
        restoreState = .restoring
        error = nil // 清除之前的错误
        Task {
            do {
                if Self.verbose {
                    os_log("\(self.t)🚀 开始恢复购买")
                }
                try await AppStore.sync()
                if Self.verbose {
                    os_log("\(self.t)✅ 恢复购买完成")
                }
                await MainActor.run {
                    restoreState = .success
                    error = nil // 清除错误信息
                    postRestore()
                }
            } catch {
                await MainActor.run {
                    restoreState = .failed
                    self.error = error
                    if Self.verbose {
                        os_log("\(self.t)❌ 恢复购买失败: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}

// MARK: - Types

/// 恢复购买状态
private enum RestoreState {
    case idle // 恢复前
    case restoring // 恢复中
    case success // 恢复成功
    case failed // 恢复失败
}

// MARK: - Supporting Views

// MARK: - Event Emitter

extension RestoreView {
    func postRestore() {
        NotificationCenter.default.post(name: .Restored, object: nil)
    }
}

// MARK: - Preview

#Preview("Restore") {
    RestoreView()
        .inRootView()
        .withDebugBar()
}

#Preview("Debug") {
    DebugView()
        .inRootView()
        .withDebugBar()
}

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
