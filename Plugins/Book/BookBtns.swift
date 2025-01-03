import SwiftUI

struct BookBtns: View {
    @EnvironmentObject var app: AppProvider
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                HStack(spacing: 0, content: {
                    Spacer()
                    BtnToggleDB(autoResize: true)
                    BtnPrev(autoResize: true)
                    BtnToggle(foregroundStyle: .white, autoResize: true)
                    BtnNext(autoResize: true)
                    BtnChapters()
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
