import MagicKit
import OSLog
import SwiftUI

struct VideoTile: View, SuperThread {
    @EnvironmentObject var playMan: PlayMan
    @EnvironmentObject var l: RootProvider

    @State var hovered = false
    
    @Binding var selection: DiskFile?

    var file: DiskFile
    
    var asset: PlayAsset { file.toPlayAsset() }

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
                    BtnToggle(asset: asset)
                    BtnShowInFinder(url: asset.url, autoResize: false)
                    BtnMore(asset: asset, autoResize: false)
                }.labelStyle(.iconOnly)
            }
        }
        .onHover(perform: { hovered = $0 })
        .onTapGesture {
            self.selection = file
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

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}
