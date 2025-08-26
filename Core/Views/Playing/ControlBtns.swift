import SwiftUI

struct ControlBtns: View {
    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var message: StateProvider
    @EnvironmentObject var man: PlayMan

    var body: some View {
        HStack {
            Spacer(minLength: 50)
            BtnToggleDB()
            man.makePreviousButton()
                .magicSize(.auto)
            man.makePlayPauseButton()
                .magicSize(.auto)
                .magicShapeVisibility(.always)
                .id(man.state.stateText)
            man.makeNextButton()
                .magicSize(.auto)
            man.makePlayModeButton()
                .magicSize(.auto)
            Spacer(minLength: 50)
        }
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Preview

#if os(macOS)
#Preview("App - Large") {
    AppPreview()
        .frame(width: 600, height: 1000)
}

#Preview("App - Small") {
    AppPreview()
        .frame(width: 500, height: 800)
}
#endif

#if os(iOS)
#Preview("iPhone") {
    AppPreview()
}
#endif


