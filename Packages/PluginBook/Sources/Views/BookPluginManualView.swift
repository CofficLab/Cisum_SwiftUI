import CisumUIComponents
import SwiftUI

/// 有声书库 说明书 —— 章节式文档。
struct BookPluginManualView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            ManualHeader(title: "有声书库", subtitle: "User Manual")

            ManualSectionHeader(number: 1, title: "概述")
            Text("管理、浏览与播放本地有声书。")
                .font(.appBody)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)

            ManualSectionHeader(number: 2, title: "核心能力")
            ManualBulletList(items: [
                .init("有声书库：管理本地有声书文件。"),
                .init("搜索：按名称快速定位有声书。"),
                .init("播放：从书库发起播放。"),
            ])

            ManualSectionHeader(number: 3, title: "基本操作")
            ManualStepList(items: [
                .init("打开有声书场景，浏览全部有声书。"),
                .init("使用搜索框按名称过滤有声书。"),
                .init("点击任意有声书开始播放。"),
            ])

            ManualSectionHeader(number: 4, title: "说明")
            ManualBulletList(items: [
                .init("有声书库依赖本地存储位置。"),
            ])
        }
        .frame(maxWidth: 620, alignment: .leading)
    }
}
