import SwiftUI

struct TopView: View {
    @EnvironmentObject var playMan: MagicPlayMan
    @EnvironmentObject var p: PluginProvider

    var asset: PlayAsset? { playMan.asset }

    var body: some View {
        HStack {
            if p.groupPlugins.count > 1 {
                BtnScene()
            }

            Spacer()
            if let asset = asset {
                HStack {
                    BtnLike(autoResize: false)
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
