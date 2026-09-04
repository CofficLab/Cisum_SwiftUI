import CisumUIComponents
import SwiftUI

/// 播放封面 说明书 —— 章节式文档。
struct PlaybackHeroPluginManualView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            ManualHeader(title: "播放封面", subtitle: "User Manual")

            ManualSectionHeader(number: 1, title: "概述")
            Text("提供播放器控制区的封面与标题展示视图，根据当前播放资源自动适配封面或视频画面。")
                .font(.appBody)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)

            ManualSectionHeader(number: 2, title: "核心能力")
            ManualBulletList(items: [
                .init("封面展示：音频资源显示封面图，视频资源显示播放画面。"),
                .init("标题显示：展示当前播放曲目的标题。"),
                .init("自适应布局：右侧封面栏可见或高度不足时仅显示标题。"),
            ])

            ManualSectionHeader(number: 3, title: "基本操作")
            ManualStepList(items: [
                .init("选择音频资源后，封面区显示对应封面与标题。"),
                .init("选择视频资源后，封面区显示视频播放画面。"),
            ])

            ManualSectionHeader(number: 4, title: "说明")
            ManualBulletList(items: [
                .init("本插件为系统级能力，始终启用，不可停用。"),
                .init("封面区通过 ControlViewProviding 注入播放控制区。"),
            ])
        }
        .frame(maxWidth: 620, alignment: .leading)
    }
}
