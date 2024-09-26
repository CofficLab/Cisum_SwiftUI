import SwiftUI

struct VideoBtns: View {
    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var data: DataProvider
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                HStack(spacing: 0, content: {
                    Spacer()
                    BtnToggleDB(autoResize: true)
                    BtnPrev(autoResize: true)
                    BtnToggle(foregroundStyle: .white, autoResize: true)
                    BtnNext(autoResize: true)
                    Text("Video")
                    if data.appScene == .Music {
                        BtnMode(autoResize: true)
                    }
                    
                    if data.appScene == .AudiosBook {
                        BtnChapters()
                    }
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
