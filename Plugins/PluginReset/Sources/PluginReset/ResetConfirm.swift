import CisumUI
import OSLog
import SwiftUI

public struct ResetConfirm: View {
    @Environment(\.dismiss) private var dismiss

    @State private var isResetting = false

    private let resetSettings: ResetSettingsAction

    public init(resetSettings: @escaping ResetSettingsAction) {
        self.resetSettings = resetSettings
    }

    public var body: some View {
        VStack(spacing: 40) {
            HStack {
                Spacer()
                closeButton
            }
            .padding(.top, 8)
            .padding(.trailing, 8)

            VStack(spacing: 16) {
                AppSheetPanel {
                    VStack(spacing: 16) {
                        AppSheetIconHeader(
                            systemImage: .cisumIconReset,
                            title: String(localized: "Reset Settings", table: "Reset", bundle: .module),
                            tint: .orange
                        )

                        if isResetting {
                            AppStatusBanner(
                                kind: .loading,
                                title: String(localized: "Resetting…", table: "Reset", bundle: .module),
                                message: String(localized: "Restoring default settings, please wait", table: "Reset", bundle: .module)
                            )
                        } else {
                            VStack(alignment: .leading, spacing: 12) {
                                AppInfoRow(
                                    icon: "externaldrive.fill",
                                    title: String(localized: "Data Storage Reset", table: "Reset", bundle: .module),
                                    description: String(localized: "Data storage will be restored to default location", table: "Reset", bundle: .module),
                                    tint: .orange
                                )

                                AppInfoRow(
                                    icon: "slider.horizontal.3",
                                    title: String(localized: "Preferences Reset", table: "Reset", bundle: .module),
                                    description: String(localized: "All user preferences will be reset", table: "Reset", bundle: .module),
                                    tint: .orange
                                )

                                AppInfoRow(
                                    icon: "exclamationmark.triangle.fill",
                                    title: String(localized: "Irreversible", table: "Reset", bundle: .module),
                                    description: String(localized: "This action cannot be undone, proceed with caution", table: "Reset", bundle: .module),
                                    tint: .orange
                                )
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }

                AppSheetActionButton(
                    title: String(localized: "Continue Reset", table: "Reset", bundle: .module),
                    systemImage: "checkmark"
                ) {
                    performReset()
                }
                .cisumIf(!isResetting)
            }
            .cisumVStackCenter()
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 24)
        .background(Color(nsColor: .windowBackgroundColor))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func performReset() {
        isResetting = true

        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            await resetSettings()

            await MainActor.run {
                dismiss()
            }
        }
    }

    private var closeButton: some View {
        Image.cisumClose
            .font(.system(size: 20, weight: .medium))
            .frame(width: 32, height: 32)
            .foregroundStyle(.secondary)
            .background(.regularMaterial, in: Circle())
            .cisumShadowSm()
            .cisumButton {
                dismiss()
            }
            .cisumHoverScale(105)
    }
}
