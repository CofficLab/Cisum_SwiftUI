import SwiftUI

struct TopView: View {
    @EnvironmentObject var playMan: PlayMan

    var asset: PlayAsset? { playMan.asset }

    var body: some View {
        HStack {
            BtnScene()
            Spacer()
            if let asset = asset {
                HStack {
                    BtnLike(asset: asset, autoResize: false)
                    if Config.isDesktop {
                        BtnShowInFinder(url: asset.url, autoResize: false)
                    }
                    BtnDel(assets: [asset], autoResize: false)
                }
            }
        }
        .padding(.horizontal)
        .labelStyle(.iconOnly)
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}
