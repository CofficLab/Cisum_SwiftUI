import MagicPlayMan
import SwiftUI

/// 播放操作按钮。
struct ControlBtns: View {
    @EnvironmentObject private var man: MagicPlayMan
    let toggleDBView: @MainActor () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Spacer(minLength: 1)

            Button(action: toggleDBView) {
                Image(systemName: "ellipsis.circle")
            }
            .buttonStyle(.plain)

            man.makePreviousButtonView()
            man.makePlayPauseButtonView()
            man.makeNextButtonView()
            man.makePlayModeButtonView()

            Spacer(minLength: 1)
        }
        .buttonStyle(.plain)
        .padding(.bottom, 20)
    }
}
