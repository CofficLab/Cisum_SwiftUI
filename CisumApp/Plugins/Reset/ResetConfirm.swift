import CisumUI
import OSLog
import SwiftUI

struct ResetConfirm: View, SuperLog {
    @Environment(\.dismiss) private var dismiss

    @State private var isResetting: Bool = false

    nonisolated static let verbose = false
    nonisolated static let emoji = "👔"

    var body: some View {
        SheetContainer {
            VStack(spacing: 16) {
                // 说明文字
                AppSheetPanel {
                    VStack(spacing: 16) {
                    AppSheetIconHeader(systemImage: .cisumIconReset, title: "Reset Settings", tint: .orange)

                    if isResetting {
                        // Resetting state
                        AppStatusBanner(kind: .loading, title: "Resetting…", message: "Restoring default settings, please wait")
                    } else {
                        // Reset description
                        VStack(alignment: .leading, spacing: 12) {
                            AppInfoRow(
                                icon: "externaldrive.fill",
                                title: String(localized: "Data Storage Reset", table: "Reset"),
                                description: String(localized: "Data storage will be restored to default location", table: "Reset"),
                                tint: .orange
                            )

                            AppInfoRow(
                                icon: "slider.horizontal.3",
                                title: String(localized: "Preferences Reset", table: "Reset"),
                                description: String(localized: "All user preferences will be reset", table: "Reset"),
                                tint: .orange
                            )

                            AppInfoRow(
                                icon: "exclamationmark.triangle.fill",
                                title: String(localized: "Irreversible", table: "Reset"),
                                description: String(localized: "This action cannot be undone, proceed with caution", table: "Reset"),
                                tint: .orange
                            )
                        }
                        .padding(.vertical, 8)
                    }
                    }
                }

                // Confirm button
                AppSheetActionButton("Continue Reset", systemImage: "checkmark") {
                    performReset()
                }
                .cisumIf(!isResetting)
            }.cisumVStackCenter()
        }
    }

    // MARK: - Actions

    private func performReset() {
        isResetting = true

        Task {
            if Self.verbose {
                os_log("\(Self.t)🔄 开始重置设置")
            }

            // 短暂延迟，让用户看到重置中的状态
            try? await Task.sleep(nanoseconds: 2000000000) // 2秒

            // 执行重置操作
            Config.resetStorageLocation()

            if Self.verbose {
                os_log("\(Self.t)✅ 重置设置完成")
            }

            await MainActor.run {
                dismiss()
            }
        }
    }
}

// MARK: - Preview

#Preview("ResetConfirm") {
    ResetConfirm()
        .inRootView()
        .withDebugBar()
}

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
