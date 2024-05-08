import OSLog
import SwiftUI

struct DBRow: View {
    @EnvironmentObject var audioManager: AudioManager

    @State var hovered = false

    var audio: Audio

    var current: Audio? { audioManager.audio }
    var db: DB { audioManager.db }
    var background: Color {
        if current?.url == audio.url {
            return Color.accentColor
        }

        return hovered ? AppConfig.getBackground.opacity(0.9) : .clear
    }

    init(_ audio: Audio) {
        self.audio = audio
//        print("\(audio.title) with duplicates -> \(audio.duplicates.count)")
    }

    var body: some View {
        ZStack {
            HStack(alignment: .center) {
                AlbumView(audio)
                    .frame(
                        width: ViewConfig.isDesktop ? 36 : 36,
                        height: ViewConfig.isDesktop ? 36 : 36
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

                        Spacer()
                    }
                }
                Spacer()
            }

            if hovered {
                HStack {
                    Spacer()
                    BtnShowInFinder(url: audio.url, autoResize: false)
                        .labelStyle(.iconOnly)
                    BtnPlay(audio: audio, autoResize: false)
                        .labelStyle(.iconOnly)
                }
            }
        }
        .onHover(perform: { hovered = $0 })
        .frame(maxHeight: .infinity)
        .contextMenu(menuItems: {
            BtnPlay(audio: audio, autoResize: false)
            Divider()
            BtnDownload(audio: audio)
            BtnEvict(audio: audio)
            if ViewConfig.isDesktop {
                BtnShowInFinder(url: audio.url, autoResize: false)
            }
            Divider()
            BtnDel(audios: [audio.id], autoResize: false)
        })
    }
}

#Preview {
    RootView {
        ContentView()
    }.modelContainer(AppConfig.getContainer())
}
