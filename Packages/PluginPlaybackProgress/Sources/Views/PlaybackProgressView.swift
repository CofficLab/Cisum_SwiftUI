import CisumUIComponents
import MagicPlayMan
import SwiftUI

/// 播放器控制区进度条视图：自观察播放进度，支持实时更新与拖动控制。
struct PlaybackProgressView: View {
    @EnvironmentObject private var man: MagicPlayMan

    var body: some View {
        man.makeProgressView()

    }
}
