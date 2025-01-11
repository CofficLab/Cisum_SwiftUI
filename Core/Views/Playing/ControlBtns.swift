import SwiftUI

struct ControlBtns: View {
    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var message: MessageProvider
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
            man.makeNextButton()
                .magicSize(.auto)
            man.makePlayModeButton()
                .magicSize(.auto)
            Spacer(minLength: 50)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}

#Preview("Layout") {
    LayoutView()
}
