import SwiftUI

struct BtnDownload: View {
    var audio: AudioModel
        
    var body: some View {
        Button {
            audio.download()
        } label: {
            Label("下载", systemImage: getImageName())
                .font(.system(size: 24))
        }
    }
    
    private func getImageName() -> String {
        return "icloud.and.arrow.down.fill"
    }
}
