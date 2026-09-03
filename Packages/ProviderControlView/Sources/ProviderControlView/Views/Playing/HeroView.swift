import MagicPlayMan
import SwiftUI

/// 播放封面区域。
struct HeroView: View {
    @EnvironmentObject private var man: MagicPlayMan
    let rightAlbumVisible: Bool

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                if !rightAlbumVisible && geometry.size.height > 450 {
                    man.makeHeroView(verbose: false)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }

                TitleView()
                    .frame(height: 60)
            }
        }
    }
}
