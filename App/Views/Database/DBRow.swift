import OSLog
import SwiftUI

struct DBRow: View {
    @EnvironmentObject var db: DB
    @EnvironmentObject var playMan: PlayMan

    @State var hovered = false

    var asset: PlayAsset

    var isCurrent: Bool {
        playMan.asset?.url == self.asset.url
    }
    var background: Color {
        if isCurrent {
            return Color.accentColor
        }
        
        if hovered {
            return Config.getBackground.opacity(0.9)
        }

        return .clear
    }

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
                        if isCurrent {
                            Image(systemName: "speaker.wave.2")
                        }
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
                    BtnPlay(asset: asset, autoResize: false)
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
    RootView {
        ContentView()
    }.modelContainer(Config.getContainer)
}
