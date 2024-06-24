import SwiftUI

struct BtnDownload: View {
    @EnvironmentObject var diskManager: DiskManager
    
    var asset: PlayAsset
    var disk: Disk { diskManager.disk }
        
    var body: some View {
        Button {
            Task {
                disk.download(asset.url, reason: "点击了下载")
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

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}

#Preview("Layout") {
    LayoutView()
}
