import SwiftUI

struct ButtonsView: View {
    var body: some View {
        HStack(spacing: 1, content: {
            ButtonToggleDatabase()
            BtnPrev()
            BtnToggle()
            BtnNext()
            BtnMode()
        })
        .foregroundStyle(.white)
        .labelStyle(.iconOnly)
#if os(iOS)
        .scaleEffect(1.2)
#endif
    }
}

#Preview {
    RootView {
        ContentView()
    }
}
