import SwiftUI

struct TopView: View {
    @EnvironmentObject var man: PlayMan
    @EnvironmentObject var p: PluginProvider

    var asset: PlayAsset? { man.asset }

    var body: some View {
        HStack {
            if p.groupPlugins.count > 1 {
                BtnScene()
            }

            Spacer()
            if let asset = asset {
                HStack {
                    man.makeLikeButton()
                    if Config.isDesktop {
                        asset.url.makeOpenButton()
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
