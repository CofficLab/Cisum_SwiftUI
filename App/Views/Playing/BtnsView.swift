import SwiftUI

struct BtnsView: View {
    @EnvironmentObject var audioManager: AudioManager

    var body: some View {
        GeometryReader { geo in
            VStack {
                HStack(spacing: 0, content: {
                    if showRow2(geo) == false {
                        BtnToggleDB()
                    }
                    BtnPrev()
                    BtnToggle()
                    BtnNext()
                    if showRow2(geo) == false {
                        BtnMode()
                    }
                })
                .foregroundStyle(.white)
                .labelStyle(.iconOnly)
                .background(.blue)
                
                if showRow2(geo) {
                    HStack(spacing: 0, content: {
                        BtnToggleDB()
                        BtnMode()
                    })
                    .foregroundStyle(.white)
                    .labelStyle(.iconOnly)
                    .background(.blue)
                }
            }
        }
    }
    
    func showRow2(_ geo: GeometryProxy) -> Bool {
        geo.size.height > AppConfig.minHeight + 100
    }
    
    func getHeight(_ geo: GeometryProxy) -> CGFloat {
        return geo.size.height
    }
}

#Preview("Layout") {
    LayoutView()
}
