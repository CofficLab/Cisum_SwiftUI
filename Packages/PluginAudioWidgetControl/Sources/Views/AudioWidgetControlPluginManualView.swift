import CisumUIComponents
import SwiftUI

/// 小组件控制 说明书 —— 章节式文档。
struct AudioWidgetControlPluginManualView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            ManualHeader(title: "小组件控制", subtitle: "User Manual")

            ManualSectionHeader(number: 1, title: "概述")
            Text("通过桌面小组件控制音乐播放。")
                .font(.appBody)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)

            ManualSectionHeader(number: 2, title: "核心能力")
            ManualBulletList(items: [
                .init("小组件：在桌面小组件中展示播放状态。"),
                .init("快捷控制：从小组件直接播放 / 暂停。"),
            ])

            ManualSectionHeader(number: 3, title: "基本操作")
            ManualStepList(items: [
                .init("在系统小组件库中添加 Cisum 播放小组件。"),
                .init("通过小组件控制播放。"),
            ])

            ManualSectionHeader(number: 4, title: "说明")
            ManualBulletList(items: [
                .init("需要系统支持桌面小组件。"),
            ])
        }
        .frame(maxWidth: 620, alignment: .leading)
    }
}
