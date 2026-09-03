import CisumUIComponents
import SwiftUI

/// 有声书场景 说明书 —— 章节式文档。
struct BookScenePluginManualView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            ManualHeader(title: "有声书场景", subtitle: "User Manual")

            ManualSectionHeader(number: 1, title: "概述")
            Text("提供「有声书」场景，是有声书功能的主入口。")
                .font(.appBody)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)

            ManualSectionHeader(number: 2, title: "核心能力")
            ManualBulletList(items: [
                .init("有声书库：有声书场景的主界面。"),
                .init("场景切换：与其他场景（音乐库）互斥切换。"),
            ])

            ManualSectionHeader(number: 3, title: "基本操作")
            ManualStepList(items: [
                .init("在场景切换器中进入有声书。"),
                .init("浏览并播放有声书。"),
            ])

            ManualSectionHeader(number: 4, title: "说明")
            ManualBulletList(items: [
                .init("场景由应用内置，固定不可扩展。"),
            ])
        }
        .frame(maxWidth: 620, alignment: .leading)
    }
}
