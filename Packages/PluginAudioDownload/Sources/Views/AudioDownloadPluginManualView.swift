import CisumUIComponents
import SwiftUI

/// 下载管理 说明书 —— 章节式文档。
struct AudioDownloadPluginManualView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            ManualHeader(title: "下载管理", subtitle: "User Manual")

            ManualSectionHeader(number: 1, title: "概述")
            Text("下载与管理音乐文件，支持离线播放。")
                .font(.appBody)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)

            ManualSectionHeader(number: 2, title: "核心能力")
            ManualBulletList(items: [
                .init("下载：将音乐下载到本地。"),
                .init("离线：下载后无需网络即可播放。"),
                .init("队列：查看与管理下载任务。"),
            ])

            ManualSectionHeader(number: 3, title: "基本操作")
            ManualStepList(items: [
                .init("选择要下载的音乐并点击下载。"),
                .init("在下载队列中查看进度。"),
                .init("下载完成后离线播放。"),
            ])

            ManualSectionHeader(number: 4, title: "说明")
            ManualBulletList(items: [
                .init("下载需要网络连接。"),
            ])
        }
        .frame(maxWidth: 620, alignment: .leading)
    }
}
