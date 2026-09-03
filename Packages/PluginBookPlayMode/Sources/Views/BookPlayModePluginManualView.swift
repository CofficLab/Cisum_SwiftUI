import CisumUIComponents
import SwiftUI

/// 有声书播放模式 说明书 —— 章节式文档。
struct BookPlayModePluginManualView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            ManualHeader(title: "有声书播放模式", subtitle: "User Manual")

            ManualSectionHeader(number: 1, title: "概述")
            Text("切换单章循环、列表循环、随机等播放模式。")
                .font(.appBody)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)

            ManualSectionHeader(number: 2, title: "核心能力")
            ManualBulletList(items: [
                .init("循环：单章 / 列表循环。"),
                .init("随机：随机播放全部章节。"),
                .init("顺序：按列表顺序播放。"),
            ])

            ManualSectionHeader(number: 3, title: "基本操作")
            ManualStepList(items: [
                .init("在播放控制区点击播放模式按钮。"),
                .init("在单章循环 / 列表循环 / 随机之间切换。"),
            ])

            ManualSectionHeader(number: 4, title: "说明")
            ManualBulletList(items: [
                .init("播放模式作用于当前播放列表。"),
            ])
        }
        .frame(maxWidth: 620, alignment: .leading)
    }
}
