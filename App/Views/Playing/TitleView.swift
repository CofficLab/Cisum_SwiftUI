import SwiftData
import SwiftUI

struct TitleView: View {
    @EnvironmentObject var audioManager: AudioManager

    var audio: Audio? { audioManager.audio }
    var characterCount: Int { audio?.title.count ?? 0 }

    var body: some View {
        GeometryReader { geo in
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    if let audio = audio {
                        Text(audio.title)
                            .foregroundStyle(.white)
                            .font(getFont(geo))
                    }
                    Spacer()
                }
                Spacer()
            }
        }
        .frame(maxHeight: .infinity)
//        .background(.blue)
    }

    func getFont(_ geo: GeometryProxy) -> Font {
        if geo.size.height < 100 {
            return .title3
        }
        
        if geo.size.height < 200 {
            return .title2
        }

        return .title
    }
}

#Preview("APP") {
    RootView {
        ContentView()
    }.modelContainer(AppConfig.getContainer())
}

#Preview("Layout") {
    LayoutPreview()
}
