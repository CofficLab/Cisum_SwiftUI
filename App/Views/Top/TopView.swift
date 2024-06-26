import SwiftUI

struct TopView: View {
    @EnvironmentObject var playMan: PlayMan

    var asset: PlayAsset? { playMan.asset }

    var body: some View {
        HStack {
            SceneView()

            Spacer()
            if let asset = asset {
                BtnLike(asset: asset, autoResize: false)
                if Config.isDesktop {
                    BtnShowInFinder(url: asset.url, autoResize: false)
                }
                BtnDel(assets: [asset], autoResize: false)
            }
            Spacer()
        }
        .labelStyle(.iconOnly)
    }
}

#Preview {
    TopView()
}
