import CisumUIComponents
import MagicPlayMan
import SwiftUI

/// 播放状态提示。
struct StateView: View {
    @EnvironmentObject private var man: MagicPlayMan
    @Environment(\.demoMode) private var isDemoMode
    let stateViews: @MainActor () -> [AnyView]
    let stateMessage: @MainActor () -> String

    var body: some View {
        if !isDemoMode, man.hasAsset || man.currentError != nil || !stateMessage().isEmpty || !stateViews().isEmpty {
            VStack(spacing: 10) {
                if !stateMessage().isEmpty {
                    infoView(stateMessage())
                }

                if man.isLoading {
                    infoView(man.state.localizedStateText(localization: man.localization))
                }

                if let error = man.currentError {
                    infoView(error.localizedDescription)
                }

                ForEach(Array(stateViews().enumerated()), id: \.offset) { _, view in
                    view
                }
            }
        }
    }

    private func infoView(_ text: String) -> some View {
        HStack {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(.white)
            Text(text)
                .foregroundStyle(.white)
        }
        .font(man.hasAsset ? .callout : .title3)
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(.secondary.opacity(0.7), in: Capsule())
    }
}
