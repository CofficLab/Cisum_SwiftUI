import CisumUIComponents
import SwiftUI

/// 文件日志 说明书 —— 章节式文档。
struct FileLogPluginManualView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            ManualHeader(title: "文件日志", subtitle: "User Manual")

            ManualSectionHeader(number: 1, title: "概述")
            Text("记录应用运行与文件操作日志，便于排查问题。")
                .font(.appBody)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)

            ManualSectionHeader(number: 2, title: "核心能力")
            ManualBulletList(items: [
                .init("日志记录：记录关键运行事件。"),
                .init("检索：按关键字检索日志。"),
                .init("清理：清理历史日志。"),
            ])

            ManualSectionHeader(number: 3, title: "基本操作")
            ManualStepList(items: [
                .init("打开日志视图查看记录。"),
                .init("按关键字检索定位问题。"),
                .init("定期清理过期日志。"),
            ])

            ManualSectionHeader(number: 4, title: "说明")
            ManualBulletList(items: [
                .init("仅在 macOS 上可用。"),
            ])
        }
        .frame(maxWidth: 620, alignment: .leading)
    }
}
