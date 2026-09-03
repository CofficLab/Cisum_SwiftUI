import CisumUIComponents
import KernelCore
import SwiftUI

/// 所有插件的默认关于页（对齐 Lumi `PluginPluginManager.PluginDefaultAboutView`）。
///
/// 插件可以贡献自己的品牌化 AboutView；没有贡献时，由插件管理器使用这
/// 个页面保证仍然提供完整、可读的插件说明。
struct PluginDefaultAboutView: View {
    @LumiTheme private var theme

    let metadata: PluginMetadata
    let isEnabled: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            LandingHero(
                icon: metadata.category.systemImage,
                accent: theme.primary,
                tagline: metadata.description.isEmpty ? "暂无详细说明" : metadata.description,
                chips: [metadata.category.displayName, metadata.stage.displayName],
                metrics: [
                    .init(value: metadata.version, label: "版本"),
                    .init(value: policyValue, label: "策略")
                ]
            )

            LandingSection(title: "核心能力", icon: "info.circle") {
                LandingFeatureGrid(items: [
                    .init(
                        icon: metadata.category.systemImage,
                        tint: theme.primary,
                        title: "分类",
                        description: metadata.category.displayName
                    ),
                    .init(
                        icon: "checkmark.seal",
                        tint: theme.success,
                        title: "阶段",
                        description: metadata.stage.displayName
                    ),
                    .init(
                        icon: "lock.shield",
                        tint: theme.warning,
                        title: "策略",
                        description: policyValue
                    ),
                    .init(
                        icon: "number.circle",
                        tint: theme.info,
                        title: "标识符",
                        description: metadata.id.isEmpty ? "未设置" : metadata.id
                    )
                ], minColumnWidth: 180)
            }

            if !metadata.permissions.isEmpty {
                LandingSection(title: "权限", icon: "hand.raised") {
                    LandingInventory(
                        tint: theme.warning,
                        items: metadata.permissions.map {
                            .init(icon: "checkmark.shield", title: "\($0.id): \($0.reason)")
                        }
                    )
                }
            }
        }
    }

    private var policyValue: String {
        switch metadata.policy {
        case .alwaysOn:
            "始终启用"
        case .disabled:
            "永久停用"
        case .optOut, .optIn:
            isEnabled ? "已启用" : "已停用"
        }
    }
}
