import SwiftUI
import MagicPlayMan

struct BtnEvict: View {
    @EnvironmentObject var playMan: MagicPlayMan

    var asset: MagicAsset
    var inUse: Bool { asset.url == playMan.asset?.url }
    var title = "移除下载项"
        
    var body: some View {
        Button {
            Task {
//                data.disk.evict(asset.url)
            }
        } label: {
            Label(title, systemImage: getImageName())
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
