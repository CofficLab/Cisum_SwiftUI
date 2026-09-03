import CisumUIComponents
import SwiftUI

/// 通用设置 说明书 —— 章节式文档。
struct SettingGeneralPluginManualView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            ManualHeader(title: "通用设置", subtitle: "User Manual")

            ManualSectionHeader(number: 1, title: "概述")
            Text("在设置窗口中提供应用信息与说明书等通用设置项。")
                .font(.appBody)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)

            ManualSectionHeader(number: 2, title: "核心能力")
            ManualBulletList(items: [
                .init("应用信息：展示名称、版本等基本信息。"),
                .init("说明书：浏览各插件的使用说明书。"),
            ])

            ManualSectionHeader(number: 3, title: "基本操作")
            ManualStepList(items: [
                .init("在设置窗口中打开「通用」标签。"),
                .init("查看应用信息。"),
                .init("点击「说明书」浏览各插件手册。"),
            ])

            ManualSectionHeader(number: 4, title: "说明")
            ManualBulletList(items: [
                .init("说明书内容由各插件贡献。"),
            ])
        }
        .frame(maxWidth: 620, alignment: .leading)
    }
}
