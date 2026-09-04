import CisumUIComponents
import MagicPlayMan
import SwiftUI

/// 播放器控制区进度条视图：自观察播放进度，支持实时更新与拖动控制。
struct PlaybackProgressView: View {
    @EnvironmentObject private var man: MagicPlayMan

    var body: some View {
        man.makeProgressView()
        #if DEBUG
        .overlay(alignment: .topTrailing) {
            DebugPluginBadge(text: PlaybackProgressPlugin.shared.id)
                .padding(8)
        }
        #endif
    }
}

/// 调试徽章 —— 仅 DEBUG 构建下叠加在插件贡献视图右上角，
/// 显示插件自身 id，便于快速识别当前渲染的贡献视图。
#if DEBUG
private struct DebugPluginBadge: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .foregroundStyle(.white)
            .background(.red.opacity(0.85), in: Capsule())
            .overlay(Capsule().strokeBorder(.white.opacity(0.5), lineWidth: 0.5))
            .shadow(color: .black.opacity(0.25), radius: 3, y: 1)
            .allowsHitTesting(false)
    }
}
#endif
