import CisumUIComponents
import MagicPlayMan
import SwiftUI

/// 播放状态提示。
struct StateView: View {
    @EnvironmentObject private var man: MagicPlayMan
    @Environment(\.demoMode) private var isDemoMode
    @LumiTheme private var appTheme
    let stateViews: @MainActor () -> [AnyView]
    let stateMessage: @MainActor () -> String

    var body: some View {
        let message = stateMessage()
        let contributedViews = stateViews()
        let hasAsset = man.hasAsset
        let currentError = man.currentError

        if !isDemoMode, hasAsset || currentError != nil || !message.isEmpty || !contributedViews.isEmpty {
            VStack(spacing: 10) {
                if !message.isEmpty {
                    infoView(message)
                }

                if man.isLoading {
                    infoView(man.state.localizedStateText(localization: man.localization))
                }

                if let error = currentError {
                    infoView(error.localizedDescription)
                }

                ForEach(Array(contributedViews.enumerated()), id: \.offset) { _, view in
                    view
                }
            }
        }
    }

    private func infoView(_ text: String) -> some View {
        HStack {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(appTheme.textPrimary)
            Text(text)
                .foregroundStyle(appTheme.textPrimary)
        }
        .font(man.hasAsset ? .callout : .title3)
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(appTheme.elevatedSurface, in: Capsule())
    }
}
