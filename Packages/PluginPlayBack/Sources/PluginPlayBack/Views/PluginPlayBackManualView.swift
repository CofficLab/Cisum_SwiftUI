import CisumUIComponents
import SwiftUI

/// 播放引擎 说明书 —— 章节式文档。
struct PluginPlayBackManualView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            ManualHeader(title: "播放引擎", subtitle: "User Manual")

            ManualSectionHeader(number: 1, title: "概述")
            Text("提供统一的播放引擎，负责音频文件的播放控制，并在重启后恢复上次播放的文件。")
                .font(.appBody)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)

            ManualSectionHeader(number: 2, title: "核心能力")
            ManualBulletList(items: [
                .init("播放引擎：驱动音频解码与播放控制。"),
                .init("状态记录：将当前播放文件写入磁盘。"),
                .init("启动恢复：重启后恢复上次播放的文件。"),
            ])

            ManualSectionHeader(number: 3, title: "基本操作")
            ManualStepList(items: [
                .init("播放任意音乐或有声书内容时，自动使用本引擎。"),
                .init("应用重启后，自动恢复上次播放的文件（仅加载，不自动播放）。"),
                .init("切换播放文件时，引擎自动记录最新文件用于下次恢复。"),
            ])

            ManualSectionHeader(number: 4, title: "说明")
            ManualBulletList(items: [
                .init("本插件为系统级能力，始终启用，不可停用。"),
            ])
        }
        .frame(maxWidth: 620, alignment: .leading)
    }
}
