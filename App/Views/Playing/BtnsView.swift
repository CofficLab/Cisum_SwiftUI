import SwiftUI

struct BtnsView: View {
    @EnvironmentObject var app: AppManager
    @EnvironmentObject var data: DataManager
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                HStack(spacing: 0, content: {
                    Spacer()
                    BtnToggleDB(autoResize: true)
                    BtnPrev(autoResize: true)
                    BtnToggle(autoResize: true)
                    BtnNext(autoResize: true)
                    if data.appScene == .Music {
                        BtnMode(autoResize: true)
                    }
                    Spacer()
                })
                .foregroundStyle(.white)
                .labelStyle(.iconOnly)
            }
        }
    }

    func getHeight(_ geo: GeometryProxy) -> CGFloat {
        return geo.size.height
    }
}

#Preview("Layout") {
    LayoutView()
}
