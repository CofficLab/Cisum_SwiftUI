import CisumUIComponents
import SwiftUI

/// 后台任务 说明书 —— 章节式文档。
struct AudioJobPluginManualView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            ManualHeader(title: "后台任务", subtitle: "User Manual")

            ManualSectionHeader(number: 1, title: "概述")
            Text("为音频文件提供后台处理任务能力。")
                .font(.appBody)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)

            ManualSectionHeader(number: 2, title: "核心能力")
            ManualBulletList(items: [
                .init("后台处理：在后台执行音频相关的任务。"),
                .init("任务调度：按队列调度与执行。"),
                .init("完成通知：任务完成后给出反馈。"),
            ])

            ManualSectionHeader(number: 3, title: "基本操作")
            ManualStepList(items: [
                .init("触发音频后台任务。"),
                .init("在任务队列中查看执行状态。"),
            ])

            ManualSectionHeader(number: 4, title: "说明")
            ManualBulletList(items: [
                .init("任务在后台异步执行，不影响前台播放。"),
            ])
        }
        .frame(maxWidth: 620, alignment: .leading)
    }
}
