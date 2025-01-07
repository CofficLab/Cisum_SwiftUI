import SwiftData
import SwiftUI

struct OperationView: View {
    @EnvironmentObject var playMan: PlayMan

    var asset: PlayAsset? { playMan.asset }
    var characterCount: Int { asset?.title.count ?? 0 }
    var geo: GeometryProxy

    var body: some View {
        HStack(spacing: 0, content: {
            Spacer()
            if let asset = asset {
                playMan.makeLikeButton()
                if Config.isDesktop {
                    asset.url.makeOpenButton()
                }
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
