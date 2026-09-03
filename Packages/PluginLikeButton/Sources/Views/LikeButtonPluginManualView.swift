import CisumUIComponents
import SwiftUI

/// 喜欢按钮 说明书 —— 章节式文档。
struct LikeButtonPluginManualView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            ManualHeader(title: "喜欢按钮", subtitle: "User Manual")

            ManualSectionHeader(number: 1, title: "概述")
            Text("在工具栏提供统一的「喜欢」按钮。")
                .font(.appBody)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)

            ManualSectionHeader(number: 2, title: "核心能力")
            ManualBulletList(items: [
                .init("工具栏按钮：在工具栏快捷标记喜欢。"),
                .init("状态同步：与各媒体喜欢状态联动。"),
            ])

            ManualSectionHeader(number: 3, title: "基本操作")
            ManualStepList(items: [
                .init("在工具栏点击心形按钮。"),
                .init("标记当前播放内容的喜欢状态。"),
            ])

            ManualSectionHeader(number: 4, title: "说明")
            ManualBulletList(items: [
                .init("当前为停用状态，可在插件管理中开启。"),
            ])
        }
        .frame(maxWidth: 620, alignment: .leading)
    }
}
