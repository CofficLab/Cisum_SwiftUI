import SwiftUI

struct ButtonsView: View {
    var body: some View {
        HStack(spacing: 2, content: {
            ButtonToggleDatabase().padding(.trailing, 20)
            BtnPrev()
            BtnToggle()
            BtnNext()
            BtnMode().padding(.leading, 20)
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
    }.frame(width: 350)
}
