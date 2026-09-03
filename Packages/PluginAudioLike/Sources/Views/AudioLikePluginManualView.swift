import CisumUIComponents
import SwiftUI

/// 音乐喜欢 说明书 —— 章节式文档。
struct AudioLikePluginManualView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            ManualHeader(title: "音乐喜欢", subtitle: "User Manual")

            ManualSectionHeader(number: 1, title: "概述")
            Text("收藏与标记喜欢的音乐。")
                .font(.appBody)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)

            ManualSectionHeader(number: 2, title: "核心能力")
            ManualBulletList(items: [
                .init("标记喜欢：一键收藏当前音乐。"),
                .init("喜欢列表：集中浏览所有喜欢的音乐。"),
            ])

            ManualSectionHeader(number: 3, title: "基本操作")
            ManualStepList(items: [
                .init("在播放页点击心形按钮标记喜欢。"),
                .init("在喜欢列表查看全部收藏。"),
            ])

            ManualSectionHeader(number: 4, title: "说明")
            ManualBulletList(items: [
                .init("默认不启用，可在插件管理中开启。"),
            ])
        }
        .frame(maxWidth: 620, alignment: .leading)
    }
}
