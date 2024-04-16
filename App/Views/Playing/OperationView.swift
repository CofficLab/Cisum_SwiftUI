import SwiftData
import SwiftUI

struct OperationView: View {
    @EnvironmentObject var audioManager: AudioManager

    var audio: Audio? { audioManager.audio }
    var characterCount: Int { audio?.title.count ?? 0 }
    var geo: GeometryProxy

    var body: some View {
        GeometryReader { geo in
            VStack {
                HStack(spacing: 0, content: {
                    Spacer()
                    if let audio = audio {
                        BtnLike(audio: audio)
                        if UIConfig.isDesktop {
                            BtnShowInFinder(url: audio.url)
                        }
                        //BtnTrash(audio: audio)
                        BtnDelSome(audios: [audio.id])
                    }
                    Spacer()
                })
                .frame(maxWidth: .infinity)
                .foregroundStyle(.white)
                .labelStyle(.iconOnly)
                .background(AppConfig.makeBackground(.red))
            }
            .frame(maxWidth: .infinity)
            .background(AppConfig.makeBackground(.yellow))
        }
        .background(AppConfig.makeBackground(.blue))
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
