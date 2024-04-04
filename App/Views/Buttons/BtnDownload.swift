import SwiftUI

struct BtnDownload: View {
    @EnvironmentObject var audioManager: AudioManager
    
    var audio: Audio
        
    var body: some View {
        Button {
            Task {
                await audioManager.db?.download(audio.url)
            }
        } label: {
            Label("下载", systemImage: getImageName())
                .font(.system(size: 24))
        }.disabled(audio.isDownloaded)
    }
    
    private func getImageName() -> String {
        return "icloud.and.arrow.down.fill"
    }
}
