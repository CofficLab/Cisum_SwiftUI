import SwiftUI

/// 播放操作按钮，对应旧版 ControlBtns。
struct ControlBtns: View {
    @ObservedObject var model: MockPlayerModel

    var body: some View {
        HStack(spacing: 22) {
            Button { model.toggleMode() } label: {
                Image(systemName: model.isShuffle ? "shuffle" : "repeat")
            }
            Button { model.previous() } label: {
                Image(systemName: "backward.fill")
            }
            Button { model.togglePlay() } label: {
                Image(systemName: model.isPlaying ? "pause.fill" : "play.fill")
                    .font(.title2.weight(.semibold))
                    .frame(width: 48, height: 48)
            }
            .buttonStyle(.borderedProminent)
            .clipShape(Circle())
            Button { model.next() } label: {
                Image(systemName: "forward.fill")
            }
            Button { model.isLiked.toggle() } label: {
                Image(systemName: model.isLiked ? "heart.fill" : "heart")
                    .foregroundStyle(model.isLiked ? Color.pink : Color.primary)
            }
        }
        .buttonStyle(.plain)
        .font(.title3)
        .padding(.top, 14)
    }
}
