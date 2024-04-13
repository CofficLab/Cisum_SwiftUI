import SwiftUI

struct BtnsView: View {
    @EnvironmentObject var audioManager: AudioManager

    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 2, content: {
                Spacer()
                BtnToggleDB().padding(.trailing, 20)
                BtnPrev()
                BtnToggle().padding(.horizontal, 10)
                BtnNext()
                BtnMode().padding(.leading, 20)
                Spacer()
            })
            .foregroundStyle(.white)
            .labelStyle(.iconOnly)
            .frame(height: getHeight(geo))
            .background(.blue)
        }
    }
    
    func getHeight(_ geo: GeometryProxy) -> CGFloat {
        return geo.size.height
    }
}

#Preview("App") {
    AppPreview()
}

#Preview("Layout") {
    LayoutPreview()
}
