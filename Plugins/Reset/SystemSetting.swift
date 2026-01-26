import MagicKit
import SwiftUI

struct SystemSetting: View, SuperLog {
    nonisolated static let emoji = "⚙️"
    nonisolated static let verbose = false

    @EnvironmentObject var app: AppProvider
    @State private var isResetting: Bool = false
    @State private var showConfirmSheet: Bool = false

    var body: some View {
        MagicSettingSection(title: "APP 信息") {
            // 版本信息
            MagicSettingRow(title: "当前版本", description: "APP 的版本", icon: "info.circle", content: {
                Text(MagicApp.getVersion())
                    .font(.footnote)
            })

            // 重置设置
            MagicSettingRow(title: "重置设置", description: "重置设置，恢复成系统默认状态", icon: .iconReset) {
                Image.reset
                    .frame(width: 28, height: 28)
                    .background(.ultraThinMaterial, in: Circle())
                    .roundedFull()
                    .hoverScale(110)
                    .inButtonWithAction(showResetConfirm)
            }
        }
        .sheet(isPresented: $showConfirmSheet) {
            ZStack {
                if isResetting {
                    ResetProgressContent()
                        .padding(24)
                        .frame(minWidth: 380)
                } else {
                    ResetConfirmContent(
                        onCancel: { showConfirmSheet = false },
                        onConfirm: performReset
                    )
                    .padding(24)
                    .frame(minWidth: 380)
                }
            }
            .background(Config.rootBackground)
        }
    }
}

// MARK: - Action

extension SystemSetting {
    func showResetConfirm() {
        showConfirmSheet = true
    }

    func performReset() {
        isResetting = true
        Task {
            Config.resetStorageLocation()
            await MainActor.run {
                isResetting = false
                showConfirmSheet = false
            }
        }
    }
}

// MARK: - Preview

#Preview("ResetConfirmContent") {
    ResetConfirmContent(onCancel: {}, onConfirm: {})
        .padding()
        .infinite()
        .frame(width: 500)
        .frame(height: 800)
        .inRootView()
}

#Preview("SystemSetting") {
    SystemSetting()
        .inRootView()
        .frame(height: 800)
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
