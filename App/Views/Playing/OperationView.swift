import SwiftData
import SwiftUI

struct OperationView: View {
    @EnvironmentObject var audioManager: AudioManager

    var audio: Audio? { audioManager.audio }
    var characterCount: Int { audio?.title.count ?? 0 }
    var geo: GeometryProxy

    var body: some View {
        HStack(spacing: 0, content: {
            Spacer()
            if let audio = audio {
                BtnLike(audio: audio, autoResize: true)
                if AppConfig.isDesktop {
                    BtnShowInFinder(url: audio.url, autoResize: true)
                }
                BtnDel(audios: [audio.id], autoResize: true)
            }
            Spacer()
        })
        .frame(maxWidth: .infinity)
        .foregroundStyle(.white)
        .labelStyle(.iconOnly)
    }

    func getFont() -> Font {
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
    LayoutView()
}
