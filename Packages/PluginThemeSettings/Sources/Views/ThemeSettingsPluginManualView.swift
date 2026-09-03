import CisumUIComponents
import SwiftUI

/// 外观设置 说明书 —— 章节式文档。
struct ThemeSettingsPluginManualView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            ManualHeader(title: "外观设置", subtitle: "User Manual")

            ManualSectionHeader(number: 1, title: "概述")
            Text("在设置窗口中提供主题选择与外观设置。")
                .font(.appBody)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)

            ManualSectionHeader(number: 2, title: "核心能力")
            ManualBulletList(items: [
                .init("主题选择：从全部主题中选择外观。"),
                .init("深色模式：切换深浅色外观。"),
            ])

            ManualSectionHeader(number: 3, title: "基本操作")
            ManualStepList(items: [
                .init("在设置窗口中打开「外观」。"),
                .init("选择心仪的主题。"),
                .init("按需切换深浅色模式。"),
            ])

            ManualSectionHeader(number: 4, title: "说明")
            ManualBulletList(items: [
                .init("主题即时应用并持久化。"),
            ])
        }
        .frame(maxWidth: 620, alignment: .leading)
    }
}
