import CisumUIComponents
import SwiftUI

/// 有声书控制 说明书 —— 章节式文档。
struct BookControlPluginManualView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            ManualHeader(title: "有声书控制", subtitle: "User Manual")

            ManualSectionHeader(number: 1, title: "概述")
            Text("控制当前有声书的播放、暂停与上下章节。")
                .font(.appBody)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)

            ManualSectionHeader(number: 2, title: "核心能力")
            ManualBulletList(items: [
                .init("播放 / 暂停：一键切换播放状态。"),
                .init("上一章：切换到上一章节。"),
                .init("下一章：切换到下一章节。"),
            ])

            ManualSectionHeader(number: 3, title: "基本操作")
            ManualStepList(items: [
                .init("在播放区域点击播放 / 暂停按钮。"),
                .init("点击上一章 / 下一章切换章节。"),
            ])

            ManualSectionHeader(number: 4, title: "说明")
            ManualBulletList(items: [
                .init("需先有正在播放的有声书。"),
            ])
        }
        .frame(maxWidth: 620, alignment: .leading)
    }
}
