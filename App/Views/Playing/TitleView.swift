import SwiftUI

struct TitleView: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var audioManager: AudioManager
    
    var body: some View {
        VStack {
            if audioManager.audio == nil {
                if audioManager.db.isAllInCloud() ?? false {
                    Label("所有文件都在 iCloud 中", systemImage: "info.circle")
                        .font(.title2)
                        .foregroundStyle(.white)
                } else {
                    Label("无可播放的文件", systemImage: "info.circle")
                        .font(.title2)
                        .foregroundStyle(.white)
                }
            } else if let audio = audioManager.audio {
                Text(audio.title).foregroundStyle(.white)
                    .font(.title2)

//                Text(audio.artist).foregroundStyle(.white)
            } else {
                Label("状态未知", systemImage: "info.circle")
                    .foregroundStyle(.white)
            }
            
            // 播放过程中出现的错误
            if let e = audioManager.playerError {
                Label(e.localizedDescription, systemImage: "info.circle")
                    .font(.callout)
                    .foregroundStyle(.white)
            }
        }
    }
}

#Preview("APP") {
    RootView {
        ContentView()
    }
}
