import CisumUIComponents
import SwiftUI

/// 播放器控制区进度条视图：自观察播放进度，支持实时更新与拖动控制。
struct PlaybackProgressView: View {
    @ObservedObject private var viewModel: PlaybackProgressViewModel

    init(viewModel: PlaybackProgressViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        MagicProgressBar(
            currentTime: Binding(
                get: { viewModel.currentTime },
                set: { viewModel.seek(to: $0) }
            ),
            duration: viewModel.duration,
            onSeek: { viewModel.seek(to: $0) }
        )
    }
}
