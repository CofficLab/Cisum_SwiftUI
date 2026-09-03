import CisumUIComponents
import SwiftUI

/// 插件管理器关于视图 —— Landing 落地页（对齐 Lumi `PluginManagerAboutView`）。
///
/// Hero 横幅 + 核心能力分区 + 入口位置分区，展示插件管理页能做什么。
struct PluginManagerAboutView: View {
    @LumiTheme private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            hero
            capabilitiesSection
            entriesSection
        }
    }

    // MARK: - Hero

    private var hero: some View {
        LandingHero(
            icon: "puzzlepiece.extension",
            accent: theme.primary,
            tagline: "管理所有已注册插件：查看、搜索、分类筛选并启停。",
            chips: ["搜索插件", "分类筛选"],
            metrics: [
                .init(value: "全部", label: "可配置插件"),
                .init(value: "始终启用", label: "策略")
            ]
        )
        .landingAppear()
    }

    // MARK: - 核心能力

    private var capabilitiesSection: some View {
        LandingSection(title: "核心能力", icon: "square.grid.2x2") {
            LandingFeatureGrid(items: [
                .init(icon: "square.grid.2x2", tint: theme.primary,
                      title: "插件目录",
                      description: "展示所有用户可配置的插件，按启用状态直观区分。"),
                .init(icon: "magnifyingglass", tint: theme.info,
                      title: "搜索过滤",
                      description: "按名称、标识符或描述关键字快速定位插件。"),
                .init(icon: "folder", tint: theme.warning,
                      title: "分类筛选",
                      description: "按媒体库 / 播放 / 主题等分类筛选列表。"),
                .init(icon: "info.circle", tint: theme.info,
                      title: "插件详情",
                      description: "展示每个插件的关于页与启用状态控件。"),
                .init(icon: "arrow.up.arrow.down", tint: theme.primary,
                      title: "启停管理",
                      description: "运行时启停插件并持久化用户覆盖设置。")
            ])
        }
        .landingAppear(delay: 0.05)
    }

    // MARK: - 入口

    private var entriesSection: some View {
        LandingSection(title: "入口位置", icon: "cursorarrow.click.2") {
            LandingInventory(
                tint: theme.primary,
                items: [
                    .init(icon: "gearshape", title: "设置 → 插件管理", description: "在主设置窗口的「插件管理」导航项中打开。"),
                    .init(icon: "book", title: "说明书", description: "可在 设置 → 通用 → 说明书 中阅读本页面的使用手册。")
                ]
            )
        }
        .landingAppear(delay: 0.1)
    }
}
