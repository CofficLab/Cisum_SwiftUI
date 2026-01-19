import MagicKit
import SwiftUI

struct ResetSetting: View, SuperLog {
    nonisolated static let emoji = "🫙"
    nonisolated static let verbose = false

    @EnvironmentObject var app: AppProvider
    @State private var isResetting: Bool = false
    @State private var showConfirmSheet: Bool = false

    var body: some View {
        MagicSettingSection {
            MagicSettingRow(title: "重置", description: "重置设置，恢复成系统默认状态", icon: .iconReset) {
                MagicButton.simple(icon: .iconReset, action: {
                    showConfirmSheet = true
                })
                .magicShape(.circle)
                .magicStyle(.secondary)
                .magicSize(.small)
            }
        }
        .sheet(isPresented: $showConfirmSheet) {
            if isResetting {
                ResetProgressContent()
                    .padding(24)
                    .frame(minWidth: 380)
            } else {
                ResetConfirmContent(
                    onCancel: { showConfirmSheet = false },
                    onConfirm: {
                        isResetting = true
                        Task {
                            Config.resetStorageLocation()
                            await MainActor.run {
                                isResetting = false
                                showConfirmSheet = false
                            }
                        }
                    }
                )
                .padding(24)
                .frame(minWidth: 380)
            }
        }
    }
}

// MARK: - Preview

#Preview("ResetConfirmContent") {
    ResetConfirmContent(onCancel: {}, onConfirm: {})
        .padding()
        .frame(width: 400)
        .inRootView()
}

#Preview("Setting") {
    SettingView()
        .background(.background)
        .frame(height: 1200)
        .inRootView()
}

#Preview("App - Large") {
    ContentView()
        .inRootView()
        .frame(width: 600, height: 1000)
}

#Preview("App - Small") {
    ContentView()
        .inRootView()
        .frame(width: 600, height: 600)
}

#if os(iOS)
    #Preview("iPhone") {
        ContentView()
            .inRootView()
    }
#endif
