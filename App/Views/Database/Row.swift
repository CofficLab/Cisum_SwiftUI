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
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                // Text("[\(audio.order)]")
                
                    
//                .frame(
//                    width: UIConfig.isDesktop ? 24 : 36,
//                    height: UIConfig.isDesktop ? 24 : 36
//                )
                AlbumView(audio)
                    .frame(
                        width: UIConfig.isDesktop ? 24 : 36,
                        height: UIConfig.isDesktop ? 24 : 36
                    )
                if current?.url == audio.url {
                    Image(systemName: "speaker.wave.2")
                        
//                            .resizable()
                }
                VStack(content: {
                    Text(audio.title)
//                        .foregroundStyle(current?.url == audio.url ? .primary : .secondary)
                })
//                Text("---\(audio.playCount)")
                Spacer()

            }
//            .padding(.leading, UIConfig.isDesktop ? 20 : 30)
//            .padding(.vertical, 1)
            .frame(maxHeight: .infinity)
//            Divider()
        }
        .frame(maxHeight: .infinity)
//        .background(background)
        .onHover(perform: { hovered = $0 })
//        .onTapGesture(count: 2, perform: {
//            audioManager.play(audio, reason: "Double Tap")
//        })
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
