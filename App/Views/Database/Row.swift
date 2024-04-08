import SwiftUI
import OSLog

struct Row: View {
    @EnvironmentObject var audioManager: AudioManager
    
    @State var hovered = false
    @State var audio: Audio
    
    var body: some View {
        ZStack {
            HStack {
//                Text("[\(audio.order.description)]")
                AlbumView(audio).frame(width: 24, height: 24)
                Text(audio.title)
                Spacer()
                if audio.isDownloading {
                    Text("\(String(format: "%.0f", audio.downloadingPercent))%").font(.footnote)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 4)
        }
        .background(getBackground())
        .onHover(perform: { hovered = $0 })
        .onTapGesture(count: 2, perform: {
            audioManager.play(audio, reason: "Double Tap")
        })
        .contextMenu(menuItems: {
            BtnPlay(audio: audio)
            BtnDownload(audio: audio)
            BtnShowInFinder(url: audio.url)
            Divider()
            BtnTrash(audio: audio)
        })
//        .task(priority: .low) {
//            watchFile()
//        }
//        .onDisappear {
//            Task {
//                await CloudHandler().stopMonitoringFile(at: audio.url)
//            }
//            NotificationCenter.default.removeObserver(self)
//        }
    }
    
//    private func watchFile() {
//        NotificationCenter.default.addObserver(
//            forName: NSNotification.Name("Updated"),
//            object: nil,
//            queue: .main,
//            using: { notification in
//                AppConfig.bgQueue.async {
//                    let data = notification.userInfo as! [String: [MetadataItemWrapper]]
//                    let items = data["items"]!
//                    items.forEach({ item in
//                        if item.url == audio.url {
//                            os_log("\(Logger.isMain)🖥️ Row::detect updated of \(audio.title)")
//                            self.audio = self.audio.mergeWith(item)
//                            return
//                        }
//                    })
//                }
//            })
//    }
    
    init(_ audio: Audio) {
        self.audio = audio
        //os_log("\(Logger.isMain)🚩 🖥️ 初始化 \(audio.title)")
    }
    
    private func getBackground() -> Color {
        if let current = audioManager.audio, current.id == audio.id {
            return AppConfig.getBackground.opacity(0.5)
        }
        
        return hovered ? AppConfig.getBackground.opacity(0.9) : AppConfig.getBackground
    }
}

#Preview {
    RootView {
        ContentView()
    }
}
