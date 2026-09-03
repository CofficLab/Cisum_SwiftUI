import CisumUIComponents
import SwiftUI

/// 音乐设置 说明书 —— 章节式文档。
struct AudioSettingsPluginManualView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            ManualHeader(title: "音乐设置", subtitle: "User Manual")

            ManualSectionHeader(number: 1, title: "概述")
            Text("提供音乐相关的设置项。")
                .font(.appBody)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)

            ManualSectionHeader(number: 2, title: "核心能力")
            ManualBulletList(items: [
                .init("播放设置：配置播放相关的偏好。"),
                .init("偏好项：集中管理音乐设置。"),
            ])

            ManualSectionHeader(number: 3, title: "基本操作")
            ManualStepList(items: [
                .init("在设置窗口中打开音乐设置。"),
                .init("按需调整播放偏好。"),
            ])

            ManualSectionHeader(number: 4, title: "说明")
            ManualBulletList(items: [
                .init("设置即时生效并持久化。"),
            ])
        }
        .frame(maxWidth: 620, alignment: .leading)
    }
}
