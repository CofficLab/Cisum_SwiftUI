import CisumUIComponents
import SwiftUI

/// 场景管理 说明书 —— 章节式文档。
struct ScenePluginManualView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            ManualHeader(title: "场景管理", subtitle: "User Manual")

            ManualSectionHeader(number: 1, title: "概述")
            Text("管理应用场景（音乐库 / 有声书）的切换与状态。")
                .font(.appBody)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)

            ManualSectionHeader(number: 2, title: "核心能力")
            ManualBulletList(items: [
                .init("场景切换：在音乐库与有声书之间切换。"),
                .init("状态管理：维护当前场景状态。"),
            ])

            ManualSectionHeader(number: 3, title: "基本操作")
            ManualStepList(items: [
                .init("在场景切换器中选择目标场景。"),
                .init("应用切换到对应场景界面。"),
            ])

            ManualSectionHeader(number: 4, title: "说明")
            ManualBulletList(items: [
                .init("场景由应用内置，固定为音乐库与有声书。"),
            ])
        }
        .frame(maxWidth: 620, alignment: .leading)
    }
}
