import CisumUIComponents
import SwiftUI

/// 复制 说明书 —— 章节式文档。
struct CopyPluginManualView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            ManualHeader(title: "复制", subtitle: "User Manual")

            ManualSectionHeader(number: 1, title: "概述")
            Text("一键复制当前音乐文件到剪贴板。")
                .font(.appBody)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)

            ManualSectionHeader(number: 2, title: "核心能力")
            ManualBulletList(items: [
                .init("复制文件：将当前播放音乐复制到剪贴板。"),
                .init("完成提示：复制完成后给出状态反馈。"),
            ])

            ManualSectionHeader(number: 3, title: "基本操作")
            ManualStepList(items: [
                .init("播放任意音乐后点击复制按钮。"),
                .init("在目标位置粘贴复制的文件。"),
            ])

            ManualSectionHeader(number: 4, title: "说明")
            ManualBulletList(items: [
                .init("仅在 macOS 上可用。"),
            ])
        }
        .frame(maxWidth: 620, alignment: .leading)
    }
}
