import MagicCore
import SwiftUI

struct ResetSetting: View, SuperLog {
    nonisolated static let emoji = "🫙"

    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var configProvider: ConfigProvider
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
                            configProvider.resetStorageLocation()
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

#Preview("ResetConfirmContent") {
    RootView {
        ResetConfirmContent(onCancel: {}, onConfirm: {})
            .padding()
            .frame(width: 400)
    }
}

#Preview("Setting") {
    RootView {
        SettingView()
            .background(.background)
    }
    .frame(height: 1200)
}

#Preview("App - Large") {
    AppPreview()
        .frame(width: 600, height: 1000)
}

#Preview("App - Small") {
    AppPreview()
        .frame(width: 500, height: 800)
}

#if os(iOS)
#Preview("iPhone") {
    AppPreview()
}
#endif
