import SwiftUI

struct ButtonDownload: View {
    var url: URL
        
    var body: some View {
        Button {
//            _ = databaseManager.downloadOne(url)
        } label: {
            Label("下载", systemImage: getImageName())
                .font(.system(size: 24))
        }
        .disabled(iCloudHelper.isDownloaded(url: url))
    }
    
    private func getImageName() -> String {
        return "icloud.and.arrow.down.fill"
    }
}
