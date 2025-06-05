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
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview("Small Screen") {
    RootView {
        ContentView()
    }
    .frame(width: 500)
    .frame(height: 1200)
}

#Preview("Big Screen") {
    RootView {
        ContentView()
    }
    .frame(width: 1200)
    .frame(height: 1200)
}

#Preview("Layout") {
    LayoutView()
}
