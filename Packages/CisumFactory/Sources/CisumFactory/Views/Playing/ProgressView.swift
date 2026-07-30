import SwiftUI

/// 播放进度，对应旧版 PlayingProgressView。
struct PlayingProgressView: View {
    @ObservedObject var model: MockPlayerModel

    var body: some View {
        VStack(spacing: 7) {
            Slider(value: $model.progress, in: 0...model.duration)
                .tint(.accentColor)

            HStack {
                Text(model.progressText)
                Spacer()
                Text(model.durationText)
            }
            .font(.caption)
            .foregroundStyle(.tertiary)
        }
    }
}
