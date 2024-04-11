import SwiftUI

struct TitleView: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var audioManager: AudioManager

    var audio: Audio? { audioManager.audio }

    var body: some View {
        VStack {
            if let audio = audio {
                Text(audio.title)
                    .foregroundStyle(.white)
                    .font(.title2)
            }

            // 播放过程中出现的错误
            if let e = audioManager.playerError {
                CardView(background: BackgroundView.type3, paddingVertical: 6) {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundStyle(.white)
                        Text(e.localizedDescription)
                            .foregroundStyle(.white)
                    }
                    .font(audio == nil ? .title3 : .callout)
                    .onAppear {
                        EventManager().onUpdated({ items in
                            for item in items {
                                if item.url == audioManager.audio?.url {
                                    audioManager.checkError()
                                    return
                                }
                            }
                        })
                    }
                }
            }
        }
    }
}

#Preview("APP") {
    RootView {
        ContentView()
    }.modelContainer(AppConfig.getContainer())
}
