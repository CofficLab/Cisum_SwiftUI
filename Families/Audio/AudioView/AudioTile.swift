import MagicKit
import OSLog
import SwiftUI

struct AudioTile: View {
    @EnvironmentObject private var playMan: PlayMan
    @EnvironmentObject private var l: FamalyProvider

    @State private var hovered = false

    let audio: Audio

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
                audioInfo
                Spacer()
            }

            if hovered {
                HStack {
                    Spacer()
                    hoverButtons
                }
            }
        }
        .onHover { isHovered in
            withAnimation(.easeInOut(duration: 0.1)) {
                hovered = isHovered
            }
        }
        .contextMenu { contextMenuItems }
    }

    private var audioInfo: some View {
        HStack {
            AudioAvatar(asset).frame(width: 36, height: 36)
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
        }
    }

    private var hoverButtons: some View {
        HStack {
            BtnToggle(asset: asset)
            BtnShowInFinder(url: asset.url, autoResize: false)
            BtnMore(asset: asset, autoResize: false)
        }.labelStyle(.iconOnly)
    }

    @ViewBuilder
    private var contextMenuItems: some View {
        BtnToggle(asset: asset)
        Divider()
        BtnDownload(asset: asset)
        BtnEvict(asset: asset)
        if Config.isDesktop {
            BtnShowInFinder(url: asset.url, autoResize: false)
        }
        Divider()
        BtnDel(assets: [asset], autoResize: false)
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}
