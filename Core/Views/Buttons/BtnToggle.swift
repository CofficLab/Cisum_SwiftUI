import AVKit
import MagicKit
import OSLog
import SwiftUI

struct BtnToggle: View, SuperThread, SuperLog {
    @EnvironmentObject var appManager: AppProvider
    @EnvironmentObject var playMan: PlayMan
    @EnvironmentObject var m: MessageProvider

    let emoji = "🔊"
    var asset: PlayAsset?
    var foregroundStyle: Color?
    var playing: Bool { playMan.playing }

    var title: String {
        if let asset = asset {
            if asset.url == playMan.asset?.url {
                return playing ? "暂停" : "播放"
            } else {
                return "播放「\(asset.title)」"
            }
        } else {
            return playing ? "暂停" : "播放"
        }
    }

    var autoResize = false

    var image: String {
        if asset != nil {
            playing && asset!.url == playMan.asset?.url ? "pause.fill" : "play.fill"
        } else {
            playing ? "pause.fill" : "play.fill"
        }
    }

    var body: some View {
        ZStack {
            if let f = foregroundStyle {
                buttonView.foregroundStyle(f)
            } else {
                buttonView
            }
        }
    }

    var buttonView: some View {
        ControlButton(
            title: title,
            image: image,
            dynamicSize: autoResize,
            onTap: onTap)
    }
}

// MARK: Event Handler

extension BtnToggle {
    func onTap() {
        do {
            if let asset = asset {
                if asset.url == playMan.asset?.url {
                    try playMan.toggle()
                } else {
                    playMan.play(asset, reason: self.className, verbose: true)
                }
            } else {
                try playMan.toggle()
            }
        } catch {
            m.alert(error.localizedDescription)
        }
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}
