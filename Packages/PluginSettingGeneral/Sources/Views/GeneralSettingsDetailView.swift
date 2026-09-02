#if canImport(AppKit)
import AppKit
#endif
import CisumUIComponents
import SwiftUI

/// 通用设置详情视图 —— 设置窗口「通用」标签页。
///
/// 对齐 Lumi `GeneralSettingsDetailView` 的分组卡片形态，按 Cisum 实际情况
/// 保留「应用信息」分组（DEBUG 下附加「调试」分组），删减了依赖 Lumi 特有
/// 能力的分组（说明书 / 官网 / 更新 / 引导重放）。
struct GeneralSettingsDetailView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                appInfoSection
                #if DEBUG
                debugSection
                #endif
            }
            .frame(maxWidth: 640, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(24)
        }
    }

    // MARK: - 应用信息

    private var appInfoSection: some View {
        settingSection(title: "应用信息") {
            settingRow(icon: "app", title: "名称", value: MagicApp.getAppName())
            Divider()
            settingRow(icon: "number", title: "Bundle ID", value: MagicApp.getBundleIdentifier())
            Divider()
            settingRow(icon: "info.circle", title: "版本", value: MagicApp.getVersion())
            Divider()
            settingRow(icon: "hammer", title: "构建", value: MagicApp.getBuildNumber())
        }
    }

    // MARK: - 调试

    #if DEBUG
    private var debugSection: some View {
        settingSection(title: "调试") {
            HStack(spacing: 12) {
                Image(systemName: "folder")
                    .frame(width: 22)
                    .foregroundStyle(.secondary)
                Text("打开数据目录")
                Spacer()
                Button("打开") {
                    openDataDirectory()
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
        }
    }

    private func openDataDirectory() {
        let bundleID = Bundle.main.bundleIdentifier ?? "com.coffic.cisum"
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?
            .appendingPathComponent(bundleID, isDirectory: true)
        guard let url = appSupport else { return }
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        #if canImport(AppKit)
        NSWorkspace.shared.open(url)
        #endif
    }
    #endif

    // MARK: - 通用组件

    /// 分组卡片：标题 + 圆角分组容器。
    private func settingSection<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            GroupBox {
                content()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    /// 只读信息行：图标 + 标题 + 右侧值。
    private func settingRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .frame(width: 22)
                .foregroundStyle(.secondary)
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.middle)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
    }
}
