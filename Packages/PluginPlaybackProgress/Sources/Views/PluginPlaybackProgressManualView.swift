import CisumUIComponents
import SwiftUI

/// 播放进度 说明书 —— 章节式文档。
struct PlaybackProgressPluginManualView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            ManualHeader(title: "播放进度", subtitle: "User Manual")

            ManualSectionHeader(number: 1, title: "概述")
            Text("提供播放器控制区的进度条视图，实时显示当前播放进度，并支持拖动控制播放位置。")
                .font(.appBody)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)

            ManualSectionHeader(number: 2, title: "核心能力")
            ManualBulletList(items: [
                .init("进度显示：实时展示当前播放位置与总时长。"),
                .init("拖动控制：拖动进度条调整播放位置。"),
            ])

            ManualSectionHeader(number: 3, title: "基本操作")
            ManualStepList(items: [
                .init("播放时进度条自动前进，展示当前进度。"),
                .init("点击或拖动进度条跳转到目标播放位置。"),
            ])

            ManualSectionHeader(number: 4, title: "说明")
            ManualBulletList(items: [
                .init("本插件为系统级能力，始终启用，不可停用。"),
                .init("进度条通过 ControlViewProviding 注入播放控制区。"),
            ])
        }
        .frame(maxWidth: 620, alignment: .leading)
    }
}
