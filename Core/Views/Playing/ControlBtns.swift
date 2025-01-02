import SwiftUI

struct ControlBtns: View {
    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var message: MessageProvider
    @EnvironmentObject var man: PlayMan

    var body: some View {
        HStack {
            Spacer()
            BtnToggleDB(autoResize: true)
            man.makePreviousButton()
            man.makePlayPauseButton()
            man.makeNextButton()
            man.makePlayModeButton()
            man.makePlaylistButton()
            Spacer()
        }
        .labelStyle(.iconOnly)
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}

#Preview("Layout") {
    LayoutView()
}
