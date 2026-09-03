import CisumUIComponents
import SwiftUI

/// 播放进度 说明书 —— 章节式文档。
struct AudioProgressPluginManualView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            ManualHeader(title: "播放进度", subtitle: "User Manual")

            ManualSectionHeader(number: 1, title: "概述")
            Text("展示与拖动音乐播放进度。")
                .font(.appBody)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)

            ManualSectionHeader(number: 2, title: "核心能力")
            ManualBulletList(items: [
                .init("进度条：展示当前播放位置。"),
                .init("拖动定位：拖动跳转到任意位置。"),
            ])

            ManualSectionHeader(number: 3, title: "基本操作")
            ManualStepList(items: [
                .init("在播放页查看当前进度。"),
                .init("拖动进度条跳转到目标位置。"),
            ])

            ManualSectionHeader(number: 4, title: "说明")
            ManualBulletList(items: [
                .init("进度条随播放实时更新。"),
            ])
        }
        .frame(maxWidth: 620, alignment: .leading)
    }
}
