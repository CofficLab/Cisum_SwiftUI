import SwiftUI

struct BtnDownload: View {
    @EnvironmentObject var db: DB
    
    var asset: PlayAsset
        
    var body: some View {
        Button {
            Task {
                await db.download(asset.url, reason: "点击了下载")
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
