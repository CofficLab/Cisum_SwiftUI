import CisumUIComponents
import SwiftUI

/// 音乐场景 说明书 —— 章节式文档。
struct AudioScenePluginManualView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            ManualHeader(title: "音乐场景", subtitle: "User Manual")

            ManualSectionHeader(number: 1, title: "概述")
            Text("提供「音乐库」场景，是音乐功能的主入口。")
                .font(.appBody)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)

            ManualSectionHeader(number: 2, title: "核心能力")
            ManualBulletList(items: [
                .init("音乐库：音乐场景的主界面。"),
                .init("场景切换：与其他场景（有声书）互斥切换。"),
            ])

            ManualSectionHeader(number: 3, title: "基本操作")
            ManualStepList(items: [
                .init("在场景切换器中进入音乐库。"),
                .init("浏览并播放音乐。"),
            ])

            ManualSectionHeader(number: 4, title: "说明")
            ManualBulletList(items: [
                .init("场景由应用内置，固定不可扩展。"),
            ])
        }
        .frame(maxWidth: 620, alignment: .leading)
    }
}
