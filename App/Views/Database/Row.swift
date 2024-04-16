import OSLog
import SwiftUI

struct Row: View {
    @EnvironmentObject var audioManager: AudioManager

    @State var hovered = false

    var audio: Audio
    var current: Audio? { audioManager.audio }
    var background: Color {
        if current?.url == audio.url {
            return Color.accentColor
        }

        return hovered ? AppConfig.getBackground.opacity(0.9) : .clear
    }

    var body: some View {
        ZStack {
            HStack(alignment: .center) {
                AlbumView(audio)
                    .frame(
                        width: UIConfig.isDesktop ? 36 : 36,
                        height: UIConfig.isDesktop ? 36 : 36
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
                        Spacer()
                    }
                }
                Spacer()
            }

            if hovered {
                HStack {
                    Spacer()
                    Button(action: {
                        audioManager.play(audio, reason: "列表的播放按钮")
                    }, label: {
                        Label("播放", systemImage: "play")
                    })
                }
            }
        }
        .onHover(perform: { hovered = $0 })
        .frame(maxHeight: .infinity)
        .contextMenu(menuItems: {
            BtnPlay(audio: audio)
            Divider()
            BtnDownload(audio: audio)
            BtnEvict(audio: audio)
            if UIConfig.isDesktop {
                BtnShowInFinder(url: audio.url, dynamicSize: false)
            }
            Divider()
            BtnTrash(audio: audio, dynamicSize: false)
        })
    }

    init(_ audio: Audio) {
        self.audio = audio
        // os_log("\(Logger.isMain)🚩 🖥️ 初始化 \(audio.title)")
    }
}

#Preview {
    RootView {
        ContentView()
    }.modelContainer(AppConfig.getContainer())
}
