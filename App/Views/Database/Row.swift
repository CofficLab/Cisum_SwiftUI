import OSLog
import SwiftUI

struct Row: View {
    @EnvironmentObject var audioManager: AudioManager

    @State var hovered = false

    var audio: Audio
    var current: Audio? { audioManager.audio }
    var background: Color {
        if current?.url == audio.url {
            return AppConfig.getBackground.opacity(0.5)
        }

        return hovered ? AppConfig.getBackground.opacity(0.9) : AppConfig.getBackground
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                // Text("[\(audio.order)]")
                AlbumView(audio)
                    .frame(
                        width: UIConfig.isDesktop ? 24 : 36,
                        height: UIConfig.isDesktop ? 24 : 36
                    )
                VStack(content: {
                    Text(audio.title)
                })
                Spacer()
            }
            .padding(.leading, UIConfig.isDesktop ? 20 : 30)
            .padding(.vertical, 1)
            .frame(maxHeight: .infinity)
            Divider()
        }
        .frame(maxHeight: .infinity)
        .background(background)
        .onHover(perform: { hovered = $0 })
        .onTapGesture(count: 2, perform: {
            audioManager.play(audio, reason: "Double Tap")
        })
        .contextMenu(menuItems: {
            BtnPlay(audio: audio)
            Divider()
            BtnDownload(audio: audio)
            BtnEvict(audio: audio)
            if UIConfig.isDesktop {
                BtnShowInFinder(url: audio.url)
            }
            Divider()
            BtnTrash(audio: audio)
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
