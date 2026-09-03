import CisumUIComponents
import SwiftUI

/// 商店 说明书 —— 章节式文档。
struct StorePluginManualView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            ManualHeader(title: "商店", subtitle: "User Manual")

            ManualSectionHeader(number: 1, title: "概述")
            Text("浏览与购买 Cisum 的增值服务与扩展。")
                .font(.appBody)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)

            ManualSectionHeader(number: 2, title: "核心能力")
            ManualBulletList(items: [
                .init("商品浏览：浏览可购买的增值服务。"),
                .init("恢复购买：恢复历史购买记录。"),
                .init("购买：完成应用内购买。"),
            ])

            ManualSectionHeader(number: 3, title: "基本操作")
            ManualStepList(items: [
                .init("在商店中浏览商品。"),
                .init("选择商品并完成购买。"),
                .init("换机后使用「恢复购买」找回权益。"),
            ])

            ManualSectionHeader(number: 4, title: "说明")
            ManualBulletList(items: [
                .init("购买通过 App Store 应用内购买完成。"),
            ])
        }
        .frame(maxWidth: 620, alignment: .leading)
    }
}
