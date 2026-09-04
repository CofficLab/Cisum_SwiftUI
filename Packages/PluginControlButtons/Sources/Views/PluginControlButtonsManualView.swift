import CisumUIComponents
import SwiftUI

/// 播放控制按钮 说明书 —— 章节式文档。
struct PluginControlButtonsManualView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            ManualHeader(title: "播放控制按钮", subtitle: "User Manual")

            ManualSectionHeader(number: 1, title: "概述")
            Text("提供播放器底部的控制按钮组，用于快速切换上一曲、播放/暂停、下一曲与播放模式。")
                .font(.appBody)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)

            ManualSectionHeader(number: 2, title: "核心能力")
            ManualBulletList(items: [
                .init("曲目切换：上一曲与下一曲快速切换。"),
                .init("播放控制：播放与暂停当前曲目。"),
                .init("播放模式：切换顺序 / 循环等播放模式。"),
                .init("更多：显示或隐藏根视图的内容视图。"),
            ])

            ManualSectionHeader(number: 3, title: "基本操作")
            ManualStepList(items: [
                .init("点击「上一曲」或「下一曲」切换曲目。"),
                .init("点击中央按钮播放或暂停当前曲目。"),
                .init("点击最右侧按钮循环切换播放模式。"),
                .init("点击「更多」按钮显示或隐藏内容视图。"),
            ])

            ManualSectionHeader(number: 4, title: "说明")
            ManualBulletList(items: [
                .init("本插件为系统级能力，始终启用，不可停用。"),
                .init("按钮组通过 ControlViewProviding 注入播放控制区。"),
            ])
        }
        .frame(maxWidth: 620, alignment: .leading)
    }
}
