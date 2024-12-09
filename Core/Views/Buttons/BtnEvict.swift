import SwiftUI

struct BtnEvict: View {
    @EnvironmentObject var playMan: PlayMan
    @EnvironmentObject var data: DataProvider

    var asset: PlayAsset
    var inUse: Bool { asset.url == playMan.asset?.url }
    var title: String {
        inUse ? "移除下载项[正在使用，不能移除]" : "移除下载项"
    }
        
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
