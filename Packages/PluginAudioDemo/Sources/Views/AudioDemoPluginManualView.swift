import CisumUIComponents
import SwiftUI

/// 音乐演示 说明书 —— 章节式文档。
struct AudioDemoPluginManualView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            ManualHeader(title: "音乐演示", subtitle: "User Manual")

            ManualSectionHeader(number: 1, title: "概述")
            Text("提供音乐播放功能的演示数据与体验。")
                .font(.appBody)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)

            ManualSectionHeader(number: 2, title: "核心能力")
            ManualBulletList(items: [
                .init("演示数据：一键生成演示音乐内容。"),
                .init("快速体验：无需真实文件即可体验播放。"),
            ])

            ManualSectionHeader(number: 3, title: "基本操作")
            ManualStepList(items: [
                .init("在演示插件中生成演示数据。"),
                .init("切换到音乐库体验演示内容。"),
            ])

            ManualSectionHeader(number: 4, title: "说明")
            ManualBulletList(items: [
                .init("演示数据仅用于体验，不替代真实媒体库。"),
            ])
        }
        .frame(maxWidth: 620, alignment: .leading)
    }
}
