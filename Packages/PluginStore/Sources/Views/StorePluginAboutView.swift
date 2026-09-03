import CisumUIComponents
import SwiftUI

/// 商店 关于视图 —— Landing 落地页。
struct StorePluginAboutView: View {
    @LumiTheme private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            LandingHero(
                icon: "cart",
                accent: theme.primary,
                tagline: "浏览与购买 Cisum 的增值服务与扩展。",
                chips: ["商店"],
                metrics: [
                    .init(value: "1.0.0", label: "版本"),
                    .init(value: "插件", label: "类型")
                ]
            )
            .landingAppear()

            LandingSection(title: "核心能力", icon: "sparkles") {
                LandingFeatureGrid(items: [
                .init(icon: "cart", tint: theme.primary, title: "商品浏览", description: "浏览可购买的增值服务。"),
                .init(icon: "checkmark.seal", tint: theme.info, title: "恢复购买", description: "恢复历史购买记录。"),
                .init(icon: "creditcard", tint: theme.success, title: "购买", description: "完成应用内购买。"),
                ], minColumnWidth: 180)
            }
            .landingAppear(delay: 0.05)
        }
    }
}
