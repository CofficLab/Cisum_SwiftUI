import SwiftUI

/// 播放状态提示，对应旧版 StateView。
struct StateView: View {
    @ObservedObject var model: MockPlayerModel

    var body: some View {
        Label(
            model.isPlaying ? "正在播放" : "已暂停",
            systemImage: model.isPlaying ? "speaker.wave.2.fill" : "pause.circle"
        )
        .font(.callout)
        .foregroundStyle(model.isPlaying ? Color.accentColor : Color.secondary)
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(.quaternary, in: Capsule())
    }
}
