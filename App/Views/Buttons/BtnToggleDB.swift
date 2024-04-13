import SwiftUI

struct BtnToggleDB: View {
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var appManager: AppManager

    var body: some View {
        GeometryReader { geo in
            VStack {
                Spacer()
                ControlButton(title: "仓库", size: getSize(geo), systemImage: "music.note.list", onTap: {
                    appManager.showDB.toggle()
                })
                Spacer()
            }
        }
        .background(.yellow)
    }
    
    func getSize(_ geo: GeometryProxy) -> CGFloat {
        return min(geo.size.height, geo.size.width)/1.5
    }
}

#Preview("App") {
    AppPreview()
}

#Preview("Layout") {
    LayoutPreview()
}
