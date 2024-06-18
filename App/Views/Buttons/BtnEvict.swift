import SwiftUI

struct BtnEvict: View {
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var db: DB
    
    var audio: Audio
        
    var body: some View {
        Button {
            Task {
                await db.evict(audio)
            }
        } label: {
            Label("移除下载项", systemImage: getImageName())
                .font(.system(size: 24))
        }.disabled(audio.url == audioManager.audio?.url)
    }
    
    private func getImageName() -> String {
        return "icloud.and.arrow.down.fill"
    }
}

#Preview("Layout") {
    LayoutView()
}
