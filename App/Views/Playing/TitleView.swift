import SwiftUI
import SwiftData

struct TitleView: View {
    @EnvironmentObject var audioManager: AudioManager

    var audio: Audio? { audioManager.audio }

    var body: some View {
        VStack {
            if let audio = audio {
                Text(audio.title)
                    .foregroundStyle(.white)
                    .font(.title2)
            }
        }
    }
}

#Preview("APP") {
    RootView {
        ContentView()
    }.modelContainer(AppConfig.getContainer())
}
