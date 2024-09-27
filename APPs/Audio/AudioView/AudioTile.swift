import MagicKit
import OSLog
import SwiftUI

struct AudioTile: View, SuperThread {
    @EnvironmentObject var playMan: PlayMan
    @EnvironmentObject var l: LayoutProvider

    @State var hovered = false
    
    var audio: Audio
    
    var asset: PlayAsset { audio.toPlayAsset() }

    init(audio: Audio) {
        let verbose = false 
        self.audio = audio

        if verbose {
            os_log("\(Logger.initLog)AudioTile -> \(audio.title)")
        }
    }

    var body: some View {
        ZStack {
            HStack {
                ZStack {
                   AudioAvatar(asset).frame(width: 36, height: 36)
                }

                VStack(alignment: .leading, spacing: 0) {
                    Text(audio.fileName)
                    HStack {
                       Text(audio.getFileSizeReadable())

                        if audio.like {
                            Image(systemName: "star.fill")
                        }
                    }
                    .font(.footnote)
                    .foregroundStyle(.secondary)
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
        .onHover { isHovered in
            withAnimation(.easeInOut(duration: 0.1)) {
                hovered = isHovered 
            }
        }
//        .onTapGesture {
//            self.bg.async {
//                self.playMan.play(audio.toPlayAsset(), reason: "AudioTile")
//            }
//        }
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
