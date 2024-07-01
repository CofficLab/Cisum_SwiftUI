import OSLog
import SwiftUI

struct DBRow: View {
    @EnvironmentObject var playMan: AudioMan

    @State var hovered = false

    var asset: PlayAsset

    init(_ asset: PlayAsset) {
        self.asset = asset
    }

    var body: some View {
        ZStack {
            HStack {
                ZStack {
                    if asset.isNotFolder() {
                        CoverView(asset)
                            .frame(width: 36, height: 36)
                    } else {
                        asset.image
                            .scaleEffect(1.4)
                            .frame(width: 24, height: 36)
                    }
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(asset.fileName)
                    if asset.isNotFolder() {
                        HStack {
                            Text(asset.getFileSizeReadable())

                            if asset.like {
                                Image(systemName: "star.fill")
                            }
                        }
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    }
                }
                Spacer()
            }

            if hovered {
                HStack {
                    Spacer()
                    BtnShowInFinder(url: asset.url, autoResize: false)
                    BtnMore(asset: asset, autoResize: false)
                }.labelStyle(.iconOnly)
            }
        }
        .onHover(perform: { hovered = $0 })
        .onTapGesture {
            playMan.play(asset, reason: "点击")
        }
        .contextMenu(menuItems: {
            BtnToggle(asset: asset)
            Divider()
            BtnDownload(asset: asset)
            BtnEvict(asset: asset)
            if Config.isDesktop {
                BtnShowInFinder(url: asset.url, autoResize: false)
            }
            Divider()
            BtnDel(assets: [asset], autoResize: false)
        })
    }
}

#Preview {
    AppPreview()
        .frame(height: 800)
}
