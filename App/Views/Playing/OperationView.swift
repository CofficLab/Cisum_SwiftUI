import SwiftData
import SwiftUI

struct OperationView: View {
    @EnvironmentObject var playMan: PlayMan
    @EnvironmentObject var db: DB

    var asset: PlayAsset? { playMan.asset }
    var characterCount: Int { asset?.title.count ?? 0 }
    var geo: GeometryProxy

    var body: some View {
        HStack(spacing: 0, content: {
            Spacer()
            if let asset = asset {
                BtnLike(asset: asset, autoResize: true)
                if Config.isDesktop {
                    BtnShowInFinder(url: asset.url, autoResize: true)
                }
                BtnDel(assets: [asset], autoResize: true)
            }
            Spacer()
        })
        .frame(maxWidth: .infinity)
        .foregroundStyle(.white)
        .labelStyle(.iconOnly)
    }

    func getFont() -> Font {
        if geo.size.height < 100 {
            return .title3
        }

        if geo.size.height < 200 {
            return .title2
        }

        return .title
    }
}

#Preview("APP") {
    AppPreview()
        .frame(height: 800)
}

#Preview("Layout") {
    LayoutView()
}
