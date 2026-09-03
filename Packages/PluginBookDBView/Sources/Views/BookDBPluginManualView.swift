import CisumUIComponents
import SwiftUI

/// 有声书数据库 说明书 —— 章节式文档。
struct BookDBPluginManualView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            ManualHeader(title: "有声书数据库", subtitle: "User Manual")

            ManualSectionHeader(number: 1, title: "概述")
            Text("以数据库视图浏览与整理有声书文件。")
                .font(.appBody)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)

            ManualSectionHeader(number: 2, title: "核心能力")
            ManualBulletList(items: [
                .init("数据库：集中管理有声书文件的数据库记录。"),
                .init("排序：按多种维度排序浏览。"),
                .init("清理：清理无效或重复的记录。"),
            ])

            ManualSectionHeader(number: 3, title: "基本操作")
            ManualStepList(items: [
                .init("打开有声书数据库视图。"),
                .init("按需筛选或排序有声书记录。"),
                .init("清理不再需要的记录。"),
            ])

            ManualSectionHeader(number: 4, title: "说明")
            ManualBulletList(items: [
                .init("数据库与书库共享存储位置。"),
            ])
        }
        .frame(maxWidth: 620, alignment: .leading)
    }
}
