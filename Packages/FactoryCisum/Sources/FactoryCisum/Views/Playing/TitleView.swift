import MagicPlayMan
import SwiftUI

/// 当前曲目标题。
///
/// 标题取自当前播放资源的文件名（无扩展）；未来可从音频库元数据补全。
struct TitleView: View {
    @EnvironmentObject private var man: MagicPlayMan

    private var title: String {
        man.currentURL?.deletingPathExtension().lastPathComponent ?? "Cisum"
    }

    var body: some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.system(size: 25, weight: .medium))
                .lineLimit(2)
                .multilineTextAlignment(.center)
            Text(man.hasAsset ? "正在播放" : "未选择资源")
                .font(.callout)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 16)
    }
}
