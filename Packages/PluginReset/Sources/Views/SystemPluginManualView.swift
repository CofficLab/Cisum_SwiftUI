import CisumUIComponents
import SwiftUI

/// 重置 说明书 —— 章节式文档。
struct SystemPluginManualView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            ManualHeader(title: "重置", subtitle: "User Manual")

            ManualSectionHeader(number: 1, title: "概述")
            Text("重置应用状态或数据，恢复初始状态。")
                .font(.appBody)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)

            ManualSectionHeader(number: 2, title: "核心能力")
            ManualBulletList(items: [
                .init("重置：将应用恢复至初始状态。"),
                .init("风险提示：重置前给出风险提示。"),
            ])

            ManualSectionHeader(number: 3, title: "基本操作")
            ManualStepList(items: [
                .init("在设置中打开「重置」。"),
                .init("确认后执行重置操作。"),
            ])

            ManualSectionHeader(number: 4, title: "说明")
            ManualBulletList(items: [
                .init("重置会清除相关数据，请谨慎操作。"),
            ])
        }
        .frame(maxWidth: 620, alignment: .leading)
    }
}
