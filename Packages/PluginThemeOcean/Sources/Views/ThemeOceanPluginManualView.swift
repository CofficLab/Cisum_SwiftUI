import CisumUIComponents
import SwiftUI

/// 海洋 说明书 —— 章节式文档。
struct ThemeOceanPluginManualView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            ManualHeader(title: "海洋", subtitle: "User Manual")

            ManualSectionHeader(number: 1, title: "概述")
            Text("清爽的海洋蓝色调主题。")
                .font(.appBody)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)

            ManualSectionHeader(number: 2, title: "核心能力")
            ManualBulletList(items: [
                .init("主题外观：「海洋」主题的整体配色与质感。"),
                .init("明暗适配：适配系统深浅色模式。"),
                .init("即时切换：切换后立即应用，无需重启。"),
            ])

            ManualSectionHeader(number: 3, title: "基本操作")
            ManualStepList(items: [
                .init("在设置 → 外观 中选择「{display}」。"),
                .init("主题立即应用到整个应用界面。"),
            ])

            ManualSectionHeader(number: 4, title: "说明")
            ManualBulletList(items: [
                .init("主题设置会持久化，重启后仍保留。"),
            ])
        }
        .frame(maxWidth: 620, alignment: .leading)
    }
}
