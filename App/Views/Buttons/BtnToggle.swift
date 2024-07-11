import AVKit
import OSLog
import SwiftUI

struct BtnToggle: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var playMan: PlayMan

    @State private var hovered: Bool = false
    @State private var systemImage = "play.fill"

    var asset: PlayAsset?
    var foregroundStyle: Color?
    
    var title: String {
        if let asset = asset {
            if asset.url == playMan.asset?.url {
                return playMan.isNotPlaying ? "播放" : "暂停"
            } else {
                return "播放「\(asset.title)」"
            }
        } else {
            return playMan.isNotPlaying ? "播放" : "暂停"
        }
    }
    var autoResize = false

    var image: String {
        if let asset = asset {
            if playMan.isPlaying, playMan.asset?.url == asset.url {
                "pause.fill"
            } else {
                "play.fill"
            }
        } else {
            if !playMan.isPlaying {
                "play.fill"
            } else {
                "pause.fill"
            }
        }
    }

    var body: some View {
        if let f = foregroundStyle {
            buttonView.foregroundStyle(f)
        } else {
            buttonView
        }
    }
    
    var buttonView: some View {
        ControlButton(
            title: title,
            image: image,
            dynamicSize: autoResize,
            onTap: {
                if let asset = asset {
                    if asset.url == playMan.asset?.url {
                        playMan.toggle()
                    } else {
                        playMan.play(asset, reason: "点击了")
                    }
                } else {
                    playMan.toggle()
                }
            })
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}
