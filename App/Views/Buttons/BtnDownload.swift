import SwiftUI

struct BtnDownload: View {
    var audio: Audio
        
    var body: some View {
        Button {
            audio.download()
        } label: {
            Label("下载", systemImage: getImageName())
                .font(.system(size: 24))
        }.disabled(audio.isDownloaded)
    }
    
    private func getImageName() -> String {
        return "icloud.and.arrow.down.fill"
    }
}
