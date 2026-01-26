import MagicKit
import MagicPlayMan
import SwiftUI

/// 播放/暂停按钮
struct PlayPauseButton: View {
    @EnvironmentObject var man: PlayMan
    @Environment(\.demoMode) var isDemoMode

    var body: some View {
        if isDemoMode {
            // 演示模式
            Button(action: {}) {
                Image.pauseFill
                    .font(.system(size: 32))
                    .foregroundColor(.blue)
                    .frame(width: 56, height: 56)
            }
            .buttonStyle(.plain)
            .shadowSm()
        } else {
            // 正常模式
            Group {
                if man.state == .playing {
                    pauseButton
                } else {
                    playButton
                }
            }
            .frame(width: 56, height: 56)
            .hoverScale(110)
        }
    }

    private var playButton: some View {
        Image.playFill
            .font(.system(size: 32))
            .foregroundColor(.blue)
            .inButtonWithAction {
                man.playCurrent(reason: "PlayPauseButton")
            }
    }

    private var pauseButton: some View {
        Image.pauseFill
            .font(.system(size: 32))
            .foregroundColor(.blue)
            .inButtonWithAction {
                man.pause(reason: "PlayPauseButton")
            }
    }
}


// MARK: - Preview

#Preview("PlayPauseButton - Playing") {
    PlayPauseButton()
        .inRootView()
        .frame(height: 800)
}

#Preview("PlayPauseButton - Paused") {
    PlayPauseButton()
        .inRootView()
        .frame(height: 800)
}

#Preview("PlayPauseButton - Demo") {
    PlayPauseButton()
        .inRootView()
        .inDemoMode()
        .frame(height: 800)
}
