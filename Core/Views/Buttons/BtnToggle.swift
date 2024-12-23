import AVKit
import MagicKit
import OSLog
import SwiftUI

struct BtnToggle: View, SuperThread, SuperLog {
    @EnvironmentObject var playMan: PlayMan
    @EnvironmentObject var m: MessageProvider

    static let emoji = "🔊"
    var foregroundStyle: Color?
    var playing: Bool { playMan.playing }

    var autoResize = false

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
            title: playing ? "暂停" : "播放",
            image: playing ? "pause.fill" : "play.fill",
            dynamicSize: autoResize,
            onTap: {
                do {
                    try playMan.toggle()
                } catch {
                    m.alert(error.localizedDescription)
                }
            })
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}
