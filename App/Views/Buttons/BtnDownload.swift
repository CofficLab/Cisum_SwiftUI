import SwiftUI

struct BtnDownload: View {
    @EnvironmentObject var audioManager: PlayManager
    
    var audio: Audio
        
    var body: some View {
        Button {
            Task {
                await audioManager.db.download(audio.url, reason: "点击了下载")
            }
        } label: {
            Label("下载", systemImage: getImageName())
                .font(.system(size: 24))
        }
    }
    
    private func getImageName() -> String {
        return "icloud.and.arrow.down.fill"
    }
}

#Preview("Layout") {
    LayoutView()
}
