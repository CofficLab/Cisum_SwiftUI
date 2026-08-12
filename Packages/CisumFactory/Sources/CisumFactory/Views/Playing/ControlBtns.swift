import MagicPlayMan
import SwiftUI

/// 播放操作按钮。
struct ControlBtns: View {
    @EnvironmentObject private var man: MagicPlayMan

    var body: some View {
        HStack(spacing: 22) {
            Button { man.togglePlayMode() } label: {
                Image(systemName: man.playMode.icon)
            }
            Button { man.previous() } label: {
                Image(systemName: "backward.fill")
            }
            Button { man.toggle(reason: "ControlBtns") } label: {
                Image(systemName: man.isPlaying ? "pause.fill" : "play.fill")
                    .font(.title2.weight(.semibold))
                    .frame(width: 48, height: 48)
            }
            .buttonStyle(.borderedProminent)
            .clipShape(Circle())
            Button { man.next() } label: {
                Image(systemName: "forward.fill")
            }
            Button { man.toggleLike() } label: {
                Image(systemName: man.isCurrentAssetLiked ? "heart.fill" : "heart")
                    .foregroundStyle(man.isCurrentAssetLiked ? Color.pink : Color.primary)
            }
        }
        .buttonStyle(.plain)
        .font(.title3)
        .padding(.top, 14)
    }
}
