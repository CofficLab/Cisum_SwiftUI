import CisumUIComponents
import SwiftUI

/// 存储管理 说明书 —— 章节式文档。
struct StoragePluginManualView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            ManualHeader(title: "存储管理", subtitle: "User Manual")

            ManualSectionHeader(number: 1, title: "概述")
            Text("管理应用数据存储位置、迁移与文件浏览。")
                .font(.appBody)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)

            ManualSectionHeader(number: 2, title: "核心能力")
            ManualBulletList(items: [
                .init("存储位置：配置数据存储目录。"),
                .init("迁移：在存储位置之间迁移数据。"),
                .init("文件浏览：浏览应用数据文件。"),
            ])

            ManualSectionHeader(number: 3, title: "基本操作")
            ManualStepList(items: [
                .init("在设置中配置存储位置。"),
                .init("需要时执行数据迁移。"),
                .init("浏览应用数据文件。"),
            ])

            ManualSectionHeader(number: 4, title: "说明")
            ManualBulletList(items: [
                .init("迁移前请确保目标位置有足够空间。"),
            ])
        }
        .frame(maxWidth: 620, alignment: .leading)
    }
}
