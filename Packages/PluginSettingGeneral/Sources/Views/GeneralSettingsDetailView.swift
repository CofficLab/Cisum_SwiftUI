#if canImport(AppKit)
import AppKit
#endif
import CisumUIComponents
import ProviderDocsView
import SwiftUI

/// 通用设置详情视图 —— 设置窗口「通用」标签页。
///
/// 对齐 Lumi `GeneralSettingsDetailView` 的分组卡片形态：保留「应用信息」
/// 分组（DEBUG 下附加「调试」分组），新增「说明书」分组（打开说明书浏览器，
/// 浏览各插件贡献的说明书），删减了依赖 Lumi 特有能力的分组（官网 / 更新 /
/// 引导重放）。
struct GeneralSettingsDetailView: View {
    /// 文档视图提供器：说明书浏览器读取全部插件贡献的 manual 条目。
    let docsProvider: (any DocsViewProviding)?

    @State private var isShowingManuals = false

    init(docsProvider: (any DocsViewProviding)? = nil) {
        self.docsProvider = docsProvider
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                appInfoSection
                manualsSection
                #if DEBUG
                debugSection
                #endif
            }
            .frame(maxWidth: 640, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(24)
        }
        .sheet(isPresented: $isShowingManuals) {
            ManualsBrowserView(manuals: docsProvider?.manualEntries ?? [])
        }
    }

    // MARK: - 应用信息

    private var appInfoSection: some View {
        settingSection(title: String(localized: "App Info", bundle: .module)) {
            settingRow(icon: "app", title: String(localized: "Name", bundle: .module), value: MagicApp.getAppName())
            Divider()
            settingRow(icon: "number", title: "Bundle ID", value: MagicApp.getBundleIdentifier())
            Divider()
            settingRow(icon: "info.circle", title: String(localized: "Version", bundle: .module), value: MagicApp.getVersion())
            Divider()
            settingRow(icon: "hammer", title: String(localized: "Build", bundle: .module), value: MagicApp.getBuildNumber())
        }
    }

    // MARK: - 说明书

    private var manualsSection: some View {
        settingSection(title: String(localized: "Manual", bundle: .module)) {
            HStack(spacing: 12) {
                Image(systemName: "book")
                    .frame(width: 22)
                    .foregroundStyle(.secondary)
                Text("Browse the manuals contributed by plugins")
                Spacer()
                Button("Open") {
                    isShowingManuals = true
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
        }
    }

    // MARK: - 调试

    #if DEBUG
    private var debugSection: some View {
        settingSection(title: "Debug") {
            HStack(spacing: 12) {
                Image(systemName: "folder")
                    .frame(width: 22)
                    .foregroundStyle(.secondary)
                Text("Open Data Directory")
                Spacer()
                Button("Open") {
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
