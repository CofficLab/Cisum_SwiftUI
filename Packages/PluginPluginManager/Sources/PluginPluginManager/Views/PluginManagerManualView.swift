import CisumUIComponents
import SwiftUI

/// 插件管理器说明书 —— 章节式文档（对齐 Lumi `PluginManagerManualView`）。
///
/// 在 设置 → 通用 → 说明书 中阅读。
struct PluginManagerManualView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            ManualHeader(title: "插件管理", subtitle: "User Manual")

            ManualSectionHeader(number: 1, title: "概述")
            Text("本说明书介绍 Cisum 的「插件管理」页面：如何查看已注册插件、搜索与分类筛选，以及如何启用或停用某个插件。")
                .font(.appBody)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)

            ManualSectionHeader(number: 2, title: "界面")
            ManualBulletList(items: [
                .init("顶部统计：显示当前可配置插件总数与已启用数量。"),
                .init("左侧列表：可搜索（名称 / 标识符 / 描述），并可按分类筛选。"),
                .init("右侧详情：展示选中插件的关于页，包含名称、描述、阶段与启用开关。")
            ])

            ManualSectionHeader(number: 3, title: "基本操作")
            ManualStepList(items: [
                .init("在搜索框输入关键字，列表即时过滤。"),
                .init("点击分类胶囊（如「媒体库」「主题」）切换筛选；再次点击「全部」清除筛选。"),
                .init("点击列表中的插件，右侧显示其关于页。"),
                .init("切换右上角的「启用」开关，即时启用或停用该插件。")
            ])

            ManualSectionHeader(number: 4, title: "说明")
            ManualBulletList(items: [
                .init("始终启用 / 已停用的插件不可配置，不显示在列表中。"),
                .init("每个插件都有关于页；未单独设计的插件会显示基于元数据的默认关于页。")
            ])
        }
        .frame(maxWidth: 620, alignment: .leading)
    }
}
