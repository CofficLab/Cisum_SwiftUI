import SwiftUI

struct TitleView: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var databaseManager: DBManager
    @EnvironmentObject var playListManager: PlayListManager
    
    var body: some View {
        VStack {
            if databaseManager.isEmpty {
                Label("无可播放的文件", systemImage: "info.circle")
                    .foregroundStyle(.white)
                    .opacity(databaseManager.audios.isEmpty ? 1 : 0)
            } else {
                Text(audioManager.audio.title).foregroundStyle(.white)
                    .font(.title2)
                    .opacity(databaseManager.audios.isEmpty ? 0 : 1)

                Text(audioManager.audio.artist).foregroundStyle(.white).opacity(databaseManager.audios.isEmpty ? 0 : 1)
            }
        }
    }
}

#Preview("APP") {
    RootView {
        ContentView()
    }
}
