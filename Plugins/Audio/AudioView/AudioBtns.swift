import SwiftUI

struct AudioBtns: View {
    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var data: DataProvider
    @EnvironmentObject var message: MessageProvider
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                HStack(spacing: 0, content: {
                    Spacer()
                    BtnToggleDB(autoResize: true)
                    BtnPrev(autoResize: true)
                    BtnToggle(foregroundStyle: .white, autoResize: true)
                    BtnNext(autoResize: true)
                    BtnMode(autoResize: true)
                    Spacer()
                })
                .labelStyle(.iconOnly)
            }
        }
    }

    func getHeight(_ geo: GeometryProxy) -> CGFloat {
        return geo.size.height
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}

#Preview("Layout") {
    LayoutView()
}
