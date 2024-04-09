import SwiftUI

struct TitleView: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var audioManager: AudioManager
    
    var audio: Audio? { audioManager.audio }

    var body: some View {
        VStack {
            if let audio = audio {
                Text(audio.title).foregroundStyle(.white)
                    .font(.title2)

//                Text(audio.artist).foregroundStyle(.white)
            }

            // 播放过程中出现的错误
            if let e = audioManager.playerError {
                Label(e.localizedDescription, systemImage: "info.circle")
                    .font(audio == nil ? .title3 : .callout)
                    .foregroundStyle(.white)
                    .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("Updated")), perform: {
                        notification in
                        AppConfig.bgQueue.async {
                            let data = notification.userInfo as! [String: [MetadataItemWrapper]]
                            let items = data["items"]!
                            for item in items {
                                if item.url == audioManager.audio?.url {
                                    audioManager.errorCheck()
                                    return
                                }
                            }
                        }
                    })
            }
        }
    }
}

#Preview("APP") {
    RootView {
        ContentView()
    }.modelContainer(AppConfig.getContainer())
}
