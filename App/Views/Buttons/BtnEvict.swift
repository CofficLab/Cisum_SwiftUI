import SwiftUI

struct BtnEvict: View {
    @EnvironmentObject var audioManager: PlayManager
    @EnvironmentObject var playMan: PlayMan
    @EnvironmentObject var db: DB
    
    var asset: PlayAsset
        
    var body: some View {
        Button {
            Task {
                await db.evict(asset.url)
            }
        } label: {
            Label("移除下载项", systemImage: getImageName())
                .font(.system(size: 24))
        }.disabled(asset.url == playMan.asset?.url)
    }
    
    private func getImageName() -> String {
        return "icloud.and.arrow.down.fill"
    }
}

#Preview("Layout") {
    LayoutView()
}
