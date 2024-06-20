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

        return hovered ? Config.getBackground.opacity(0.9) : .clear
    }

    init(_ audio: Audio) {
        self.audio = audio
    }

    var body: some View {
        ZStack {
            HStack(alignment: .center) {
                AlbumView(audio.toPlayAsset())
                    .frame(
                        width: Config.isDesktop ? 36 : 36,
                        height: Config.isDesktop ? 36 : 36
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
                    BtnPlay(asset: audio.toPlayAsset(), autoResize: false)
                    BtnMore(asset: audio.toPlayAsset(), autoResize: false)
                }.labelStyle(.iconOnly)
            }
        }
        .onHover(perform: { hovered = $0 })
        .frame(maxHeight: .infinity)
        .contextMenu(menuItems: {
            BtnPlay(asset: audio.toPlayAsset(), autoResize: false)
            Divider()
            BtnDownload(asset: audio.toPlayAsset())
            BtnEvict(asset: audio.toPlayAsset())
            if Config.isDesktop {
                BtnShowInFinder(url: audio.url, autoResize: false)
            }
            Divider()
            BtnDel(assets: [audio.toPlayAsset()], autoResize: false)
        })
        
    }
}

#Preview {
    RootView {
        ContentView()
    }.modelContainer(Config.getContainer)
}
