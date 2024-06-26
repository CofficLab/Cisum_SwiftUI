import OSLog
import SwiftUI

struct DBRow: View {
    @EnvironmentObject var playMan: PlayMan

    @State var hovered = false

    var asset: PlayAsset

    init(_ asset: PlayAsset) {
        self.asset = asset
    }

    var body: some View {
        ZStack {
            HStack(alignment: .center) {
                AlbumView(asset)
                    .frame(
                        width: Config.isDesktop ? 36 : 36,
                        height: Config.isDesktop ? 36 : 36
                    )
                VStack(spacing: 0) {
                    HStack {
                        Text(asset.title)
                        Spacer()
                    }
                    HStack {
                        Text(asset.getFileSizeReadable())
                            .foregroundStyle(.secondary)

                        if asset.like {
                            Image(systemName: "star.fill")
                        }

                        Spacer()
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
        .frame(maxHeight: .infinity)
        .contextMenu(menuItems: {
            BtnPlay(asset: asset, autoResize: false)
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
    BootView {
        ContentView()
    }.modelContainer(Config.getContainer)
}
