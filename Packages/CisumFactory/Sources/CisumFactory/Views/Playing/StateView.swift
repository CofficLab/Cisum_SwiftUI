import MagicPlayMan
import SwiftUI

/// 播放状态提示。
struct StateView: View {
    @EnvironmentObject private var man: MagicPlayMan

    var body: some View {
        Label(
            man.isPlaying ? "正在播放" : man.hasAsset ? "已暂停" : "待机",
            systemImage: man.isPlaying ? "speaker.wave.2.fill" : "pause.circle"
        )
        .font(.callout)
        .foregroundStyle(man.isPlaying ? Color.accentColor : Color.secondary)
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(.quaternary, in: Capsule())
    }
}
