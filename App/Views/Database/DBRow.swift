import OSLog
import SwiftUI

struct DBRow: View {
    @EnvironmentObject var db: DB
    @EnvironmentObject var audioManager: PlayManager

    @State var hovered = false

    var audio: Audio

    var current: PlayAsset? { audioManager.asset }
    var background: Color {
        if current?.url == audio.url {
            return Color.accentColor
        }

        return hovered ? AppConfig.getBackground.opacity(0.9) : .clear
    }

    init(_ audio: Audio) {
        self.audio = audio
    }

    var body: some View {
        ZStack {
            HStack(alignment: .center) {
                AlbumView(audio.toPlayAsset())
                    .frame(
                        width: AppConfig.isDesktop ? 36 : 36,
                        height: AppConfig.isDesktop ? 36 : 36
                    )
                VStack(spacing: 0) {
                    HStack {
                        Text(audio.title)
                        if current?.url == audio.url {
                            Image(systemName: "speaker.wave.2")
                        }
                        Spacer()
                    }
                    HStack {
                        Text(audio.getFileSizeReadable())
                            .foregroundStyle(.secondary)

//                        Duplicates(audio)
                        
//                        if audio.like {
//                            Image(systemName: "star.fill")
//                        }

                        Spacer()
                    }
                }
                Spacer()
            }

            if hovered {
                HStack {
                    Spacer()
                    BtnShowInFinder(url: audio.url, autoResize: false)
                    BtnPlay(audio: audio, autoResize: false)
                    BtnMore(audio: audio, autoResize: false)
                }.labelStyle(.iconOnly)
            }
        }
        .onHover(perform: { hovered = $0 })
        .frame(maxHeight: .infinity)
        .contextMenu(menuItems: {
            BtnPlay(audio: audio, autoResize: false)
            Divider()
            BtnDownload(audio: audio)
            BtnEvict(audio: audio)
            if AppConfig.isDesktop {
                BtnShowInFinder(url: audio.url, autoResize: false)
            }
            Divider()
            BtnDel(audios: [audio], autoResize: false)
        })
        
    }
}

#Preview {
    RootView {
        ContentView()
    }.modelContainer(AppConfig.getContainer)
}
