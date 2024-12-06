import AVKit
import MagicKit
import OSLog
import SwiftUI

struct BtnToggle: View, SuperThread, SuperLog {
    @EnvironmentObject var appManager: AppProvider
    @EnvironmentObject var playMan: PlayMan
    @EnvironmentObject var m: MessageProvider

    @State private var hovered: Bool = false
    @State private var systemImage = "play.fill"
    @State private var isPlaying = false

    let emoji = "🔊"
    var asset: PlayAsset?
    var foregroundStyle: Color?

    var title: String {
        if let asset = asset {
            if asset.url == playMan.asset?.url {
                return isPlaying ? "暂停" : "播放"
            } else {
                return "播放「\(asset.title)」"
            }
        } else {
            return isPlaying ? "暂停" : "播放"
        }
    }

    var autoResize = false

    var image: String {
        if asset != nil {
            if isPlaying {
                "pause.fill"
            } else {
                "play.fill"
            }
        } else {
            if !isPlaying {
                "play.fill"
            } else {
                "pause.fill"
            }
        }
    }

    var body: some View {
        ZStack {
            if let f = foregroundStyle {
                buttonView.foregroundStyle(f)
            } else {
                buttonView
            }

        }.onReceive(NotificationCenter.default.publisher(for: .PlayManStateChange), perform: onPlayStateChange)
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
                    try playMan.play(asset, reason: "点击了BtnToggle")
                }
            } else {
                try playMan.toggle()
            }
        } catch {
            m.alert(error.localizedDescription)
        }
    }

    func onPlayStateChange(_ notification: Notification) {
        let verbose = false
        if verbose {
            os_log("\(self.t) OnPlayStateChange")
        }

        if let state = notification.userInfo?["state"] as? PlayState {
            if self.asset == nil {
                self.isPlaying = state.isPlaying
            } else {
                if state.getPlayingAsset() != nil {
                    self.isPlaying = state.isPlaying
                } else {
                    self.isPlaying = false
                }
            }
        }
    }
}

extension Notification.Name {
    static let BtnToggleTap = Notification.Name("BtnToggleTap")
}

extension BtnToggle {
    func emitTap() {
        NotificationCenter.default.post(name: .BtnToggleTap, object: nil)
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}
