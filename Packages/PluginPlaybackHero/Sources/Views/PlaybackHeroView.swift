import CisumUIComponents
import SwiftUI

/// 播放器控制区封面/标题视图。
///
/// 复刻原 ControlView 默认 HeroView 的行为：右侧封面栏可见（宽度 > 768）或
/// 高度不足时只显示标题，否则显示主封面与标题。
struct PlaybackHeroView: View {
    @ObservedObject private var viewModel: PlaybackHeroViewModel

    init(viewModel: PlaybackHeroViewModel) {
        self.viewModel = viewModel
    }

    private var title: String {
        viewModel.currentURL?.deletingPathExtension().lastPathComponent ?? ""
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                if !(geometry.size.width > 768) && geometry.size.height > 450 {
                    viewModel.makeMediaView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }

                Text(title)
                    .font(.system(size: 24))
                    .lineLimit(2)
                    .minimumScaleFactor(0.3)
                    .multilineTextAlignment(.center)
                    .frame(width: max(0, geometry.size.width - 32))
                    .frame(height: 60)
            }
        }

    }
}
