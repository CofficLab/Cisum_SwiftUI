import MagicPlayMan
import SwiftUI

/// 当前曲目标题。
///
/// 标题取自当前播放资源的文件名（无扩展）；未来可从音频库元数据补全。
struct TitleView: View {
    @EnvironmentObject private var man: MagicPlayMan

    private var title: String { man.currentURL?.deletingPathExtension().lastPathComponent ?? "" }

    var body: some View {
        GeometryReader { geometry in
            Text(title)
                .font(.system(size: 24))
                .lineLimit(2)
                .minimumScaleFactor(0.3)
                .multilineTextAlignment(.center)
                .frame(width: max(0, geometry.size.width - 32))
                .frame(maxHeight: .infinity)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
    }
}
