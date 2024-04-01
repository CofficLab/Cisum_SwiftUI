import SwiftUI

struct BtnsView: View {
    var body: some View {
        HStack(spacing: 2, content: {
            BtnToggleDB().padding(.trailing, 20)
            BtnPrev()
            BtnToggle().padding(.horizontal, 10)
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
