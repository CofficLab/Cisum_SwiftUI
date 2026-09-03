import CisumUIComponents
import SwiftUI

/// 欢迎页 说明书 —— 章节式文档。
struct WelcomePluginManualView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            ManualHeader(title: "欢迎页", subtitle: "User Manual")

            ManualSectionHeader(number: 1, title: "概述")
            Text("首次启动时展示欢迎引导，帮助快速上手。")
                .font(.appBody)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)

            ManualSectionHeader(number: 2, title: "核心能力")
            ManualBulletList(items: [
                .init("欢迎引导：首次启动展示欢迎内容。"),
                .init("快速上手：引导配置存储与基本操作。"),
            ])

            ManualSectionHeader(number: 3, title: "基本操作")
            ManualStepList(items: [
                .init("首次启动时按引导完成基本设置。"),
                .init("跳过或完成欢迎引导。"),
            ])

            ManualSectionHeader(number: 4, title: "说明")
            ManualBulletList(items: [
                .init("仅首次启动或重置后展示。"),
            ])
        }
        .frame(maxWidth: 620, alignment: .leading)
    }
}
