import SwiftUI

struct TopView: View {
    @EnvironmentObject var playMan: PlayMan

    var asset: PlayAsset? { playMan.asset }

    var body: some View {
        HStack {
            if Config.isDebug {
                SceneView()
            }

            Spacer()
            if let asset = asset {
                HStack {
                    BtnLike(asset: asset, autoResize: false)
                    if Config.isDesktop {
                        BtnShowInFinder(url: asset.url, autoResize: false)
                    }
                    BtnDel(assets: [asset], autoResize: false)
                }.padding(.trailing)
            }
        }
        .labelStyle(.iconOnly)
        .foregroundStyle(.white)
    }
}

#Preview {
    TopView()
}
