import SwiftUI

struct BtnsView: View {
    @EnvironmentObject var audioManager: AudioManager

    var body: some View {
        GeometryReader { geo in
            VStack {
                HStack(spacing: 0, content: {
                    Spacer()
                    if showRow2(geo) == false {
                        BtnToggleDB(autoResize: true)
                    }
                    BtnPrev(autoResize: true)
                    BtnToggle(autoResize: true)
                    BtnNext(autoResize: true)
                    if showRow2(geo) == false {
                        BtnMode(autoResize: true)
                    }
                    Spacer()
                })
                .foregroundStyle(.white)
                .labelStyle(.iconOnly)
//                .background(.blue)

                if showRow2(geo) {
                    HStack(spacing: 0, content: {
                        BtnToggleDB()
                        BtnMode()
                    })
                    .foregroundStyle(.white)
                    .labelStyle(.iconOnly)
//                    .background(.blue)
                }
            }
//            .frame(maxHeight: .infinity)
            .background(.blue.opacity(0))
        }
    }

    func showRow2(_ geo: GeometryProxy) -> Bool {
        geo.size.height > AppConfig.minHeight + 10000
    }

    func getHeight(_ geo: GeometryProxy) -> CGFloat {
        return geo.size.height
    }
}

#Preview("Layout") {
    LayoutView()
}
