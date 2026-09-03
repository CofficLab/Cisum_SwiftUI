import CisumUIComponents
import SwiftUI

/// 打开当前 说明书 —— 章节式文档。
struct OpenButtonPluginManualView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            ManualHeader(title: "打开当前", subtitle: "User Manual")

            ManualSectionHeader(number: 1, title: "概述")
            Text("在工具栏提供「打开当前」入口，快速定位当前播放文件。")
                .font(.appBody)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)

            ManualSectionHeader(number: 2, title: "核心能力")
            ManualBulletList(items: [
                .init("打开文件：在文件管理器中显示当前文件。"),
                .init("快速跳转：一键定位当前播放内容。"),
            ])

            ManualSectionHeader(number: 3, title: "基本操作")
            ManualStepList(items: [
                .init("在工具栏点击「打开当前」按钮。"),
                .init("在文件管理器中查看当前播放文件。"),
            ])

            ManualSectionHeader(number: 4, title: "说明")
            ManualBulletList(items: [
                .init("需当前有正在播放的内容。"),
            ])
        }
        .frame(maxWidth: 620, alignment: .leading)
    }
}
