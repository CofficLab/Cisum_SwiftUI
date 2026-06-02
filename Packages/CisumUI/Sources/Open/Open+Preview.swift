#if macOS
    import SwiftUI

    // MARK: - Preview Case Models

    /// 预览案例分类
    enum PreviewCategory: String, CaseIterable {
        case webLinks = "网络链接"
        case localFiles = "本地文件"
        case textEditors = "文本编辑器"
        case developerTools = "开发工具"
        case browsers = "浏览器"
        case otherTools = "其他工具"

        var icon: String {
            switch self {
            case .webLinks:
                return "link"
            case .localFiles:
                return "doc"
            case .textEditors:
                return "text.alignleft"
            case .developerTools:
                return "hammer"
            case .browsers:
                return "globe"
            case .otherTools:
                return "wrench.and.screwdriver"
            }
        }
    }

    /// 预览案例
    struct PreviewCase: Identifiable, Hashable {
        let id = UUID()
        let title: String
        let category: PreviewCategory
        let url: URL
        let appType: OpenAppType
        let useRealIcon: Bool
        let description: String

        static let allCases: [PreviewCase] = [
            // 网络链接
            PreviewCase(
                title: "智能打开",
                category: .webLinks,
                url: .sample_web_mp3_kennedy,
                appType: .auto,
                useRealIcon: false,
                description: "自动识别链接类型，网络链接使用浏览器打开"
            ),
            PreviewCase(
                title: "默认浏览器",
                category: .webLinks,
                url: .sample_web_mp3_kennedy,
                appType: .browser,
                useRealIcon: false,
                description: "在系统默认浏览器中打开"
            ),
            PreviewCase(
                title: "Safari 浏览器",
                category: .webLinks,
                url: .sample_web_mp3_kennedy,
                appType: .safari,
                useRealIcon: false,
                description: "在 Safari 浏览器中打开"
            ),
            PreviewCase(
                title: "Chrome 浏览器",
                category: .webLinks,
                url: .sample_web_mp3_kennedy,
                appType: .chrome,
                useRealIcon: false,
                description: "在 Chrome 浏览器中打开"
            ),

            // 本地文件
            PreviewCase(
                title: "智能打开文件",
                category: .localFiles,
                url: .sample_temp_txt,
                appType: .auto,
                useRealIcon: false,
                description: "自动识别文件类型，本地文件在访达中显示"
            ),
            PreviewCase(
                title: "在访达中显示",
                category: .localFiles,
                url: .sample_temp_txt,
                appType: .finder,
                useRealIcon: false,
                description: "在访达中显示并选中文件"
            ),
            PreviewCase(
                title: "预览应用",
                category: .localFiles,
                url: .sample_temp_txt,
                appType: .preview,
                useRealIcon: false,
                description: "在预览应用中打开文件"
            ),

            // 文本编辑器
            PreviewCase(
                title: "系统文本编辑",
                category: .textEditors,
                url: .sample_temp_txt,
                appType: .textEdit,
                useRealIcon: false,
                description: "在系统文本编辑器中打开"
            ),
            PreviewCase(
                title: "Xcode（系统图标）",
                category: .textEditors,
                url: .sample_temp_txt,
                appType: .xcode,
                useRealIcon: false,
                description: "使用 SF Symbol 图标"
            ),
            PreviewCase(
                title: "Xcode（真实图标）",
                category: .textEditors,
                url: .sample_temp_txt,
                appType: .xcode,
                useRealIcon: true,
                description: "使用真实应用图标（如果已安装）"
            ),
            PreviewCase(
                title: "VS Code（系统图标）",
                category: .textEditors,
                url: .sample_temp_txt,
                appType: .vscode,
                useRealIcon: false,
                description: "使用 SF Symbol 图标"
            ),
            PreviewCase(
                title: "VS Code（真实图标）",
                category: .textEditors,
                url: .sample_temp_txt,
                appType: .vscode,
                useRealIcon: true,
                description: "使用真实应用图标（如果已安装）"
            ),
            PreviewCase(
                title: "Cursor 编辑器",
                category: .textEditors,
                url: .sample_temp_txt,
                appType: .cursor,
                useRealIcon: false,
                description: "在 Cursor AI 编辑器中打开"
            ),
            PreviewCase(
                title: "Trae 开发工具",
                category: .textEditors,
                url: .sample_temp_txt,
                appType: .trae,
                useRealIcon: false,
                description: "在 Trae 开发工具中打开"
            ),
            PreviewCase(
                title: "Antigravity AI 编辑器",
                category: .textEditors,
                url: .sample_temp_txt,
                appType: .antigravity,
                useRealIcon: false,
                description: "在 Antigravity AI 编辑器中打开"
            ),

            // 开发工具
            PreviewCase(
                title: "GitHub Desktop",
                category: .developerTools,
                url: .sample_temp_txt,
                appType: .githubDesktop,
                useRealIcon: false,
                description: "在 GitHub Desktop 中打开"
            ),
            PreviewCase(
                title: "终端",
                category: .developerTools,
                url: .sample_temp_txt,
                appType: .terminal,
                useRealIcon: false,
                description: "在终端中打开"
            ),
            PreviewCase(
                title: "Kiro",
                category: .developerTools,
                url: .sample_temp_txt,
                appType: .kiro,
                useRealIcon: false,
                description: "在 Kiro 中打开"
            ),

            // 浏览器
            PreviewCase(
                title: "Arc 浏览器",
                category: .browsers,
                url: .sample_web_mp3_kennedy,
                appType: .arc,
                useRealIcon: false,
                description: "在 Arc 浏览器中打开（如果已安装）"
            ),
            PreviewCase(
                title: "Firefox 浏览器",
                category: .browsers,
                url: .sample_web_mp3_kennedy,
                appType: .firefox,
                useRealIcon: false,
                description: "在 Firefox 浏览器中打开（如果已安装）"
            ),
            PreviewCase(
                title: "Edge 浏览器",
                category: .browsers,
                url: .sample_web_mp3_kennedy,
                appType: .edge,
                useRealIcon: false,
                description: "在 Edge 浏览器中打开（如果已安装）"
            ),

            // 其他工具
            PreviewCase(
                title: "终端",
                category: .otherTools,
                url: .sample_temp_txt,
                appType: .terminal,
                useRealIcon: false,
                description: "在终端中打开"
            ),
            PreviewCase(
                title: "预览",
                category: .otherTools,
                url: .sample_temp_txt,
                appType: .preview,
                useRealIcon: false,
                description: "在预览应用中打开"
            ),
        ]

        /// 按分类分组
        static func grouped() -> [(category: PreviewCategory, cases: [PreviewCase])] {
            Dictionary(grouping: allCases, by: { $0.category })
                .map { ($0.key, $0.value) }
                .sorted { $0.category.rawValue < $1.category.rawValue }
        }
    }

    // MARK: - Main Preview View

    struct OpenPreivewView: View {
        @State private var selectedCase: PreviewCase?

        var body: some View {
            NavigationSplitView {
                // 侧边栏
                SidebarView(selectedCase: $selectedCase)
            } detail: {
                // 详情视图
                DetailView(selectedCase: selectedCase)
            }
            .navigationSplitViewStyle(.balanced)
        }
    }

    // MARK: - Sidebar View

    struct SidebarView: View {
        @Binding var selectedCase: PreviewCase?

        var body: some View {
            List(selection: $selectedCase) {
                ForEach(PreviewCase.allCases) { previewCase in
                    HStack {
                        Image(systemName: previewCase.appType.icon(for: previewCase.url))
                            .frame(width: 16)
                        Text(previewCase.title)
                        if previewCase.useRealIcon {
                            Image(systemName: "app.badge.checkmark")
                                .font(.caption2)
                                .foregroundColor(.green)
                        }
                        Spacer()
                        if previewCase.appType.isInstalled {
                            Circle()
                                .fill(.green)
                                .frame(width: 6, height: 6)
                        } else {
                            Circle()
                                .fill(.gray.opacity(0.3))
                                .frame(width: 6, height: 6)
                        }
                    }
                    .tag(previewCase)
                }
            }
            .navigationSplitViewColumnWidth(min: 200, ideal: 250)
        }
    }

    // MARK: - Detail View

    struct DetailView: View {
        let selectedCase: PreviewCase?

        var body: some View {
            if let previewCase = selectedCase {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // 标题区域
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: previewCase.category.icon)
                                    .font(.title2)
                                    .foregroundColor(.accentColor)
                                Text(previewCase.title)
                                    .font(.title2.bold())
                                Spacer()
                            }

                            Text(previewCase.description)
                                .foregroundColor(.secondary)
                        }
                        .padding(.bottom, 8)

                        Divider()

                        // 按钮展示区域
                        VStack(alignment: .leading, spacing: 16) {
                            Text("按钮预览")
                                .font(.headline)

                            HStack(spacing: 30) {
                                // 系统图标
                                VStack(spacing: 8) {
                                    previewCase.url.makeOpenButton(
                                        previewCase.appType,
                                        useRealIcon: false
                                    )
                                    .frame(width: 48, height: 48)

                                    Text("系统图标")
                                        .font(.caption)
                                        .foregroundColor(.secondary)

                                    Text("SF Symbol")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                .frame(width: 100, alignment: .center)

                                Divider()
                                    .frame(height: 60)

                                // 真实图标
                                VStack(spacing: 8) {
                                    #if os(macOS)
                                    if previewCase.appType.isInstalled {
                                        previewCase.url.makeOpenButton(
                                            previewCase.appType,
                                            useRealIcon: true
                                        )
                                        .frame(width: 48, height: 48)

                                        Text("真实图标")
                                            .font(.caption)
                                            .foregroundColor(.secondary)

                                        Text("Installed")
                                            .font(.caption2)
                                            .foregroundColor(.green)
                                    } else {
                                        Image(systemName: "questionmark.app")
                                            .font(.system(size: 32))
                                            .foregroundColor(.secondary)
                                            .frame(width: 48, height: 48)

                                        Text("真实图标")
                                            .font(.caption)
                                            .foregroundColor(.secondary)

                                        Text("Not Installed")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                    #else
                                    Image(systemName: previewCase.appType.icon(for: previewCase.url))
                                        .font(.system(size: 32))
                                        .foregroundColor(.secondary)
                                        .frame(width: 48, height: 48)

                                    Text("真实图标")
                                        .font(.caption)
                                        .foregroundColor(.secondary)

                                    Text("iOS - N/A")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                    #endif
                                }
                                .frame(width: 120, alignment: .center)
                            }
                            .padding(.vertical, 8)
                        }

                        Divider()

                        // 详细信息
                        VStack(alignment: .leading, spacing: 12) {
                            Text("详细信息")
                                .font(.headline)

                            InfoRow(label: "应用类型", value: previewCase.appType.displayName)
                            InfoRow(label: "Bundle ID", value: previewCase.appType.bundleId ?? "无")
                            InfoRow(label: "系统图标", value: previewCase.appType.icon(for: previewCase.url))
                            InfoRow(label: "文件路径", value: previewCase.url.path)
                            InfoRow(label: "文件类型", value: previewCase.url.pathExtension.isEmpty ? "无扩展名" : previewCase.url.pathExtension)
                        }

                        Spacer()
                    }
                    .padding()
                }
            } else {
                // 空状态
                VStack(spacing: 16) {
                    Image(systemName: "sidebar.left")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)

                    Text("请从侧边栏选择一个预览案例")
                        .font(.title3)
                        .foregroundColor(.secondary)

                    Text("左侧显示了所有可用的打开按钮示例")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    // MARK: - Info Row Component

    struct InfoRow: View {
        let label: String
        let value: String

        var body: some View {
            HStack(alignment: .top) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 80, alignment: .leading)

                Text(value)
                    .font(.caption)
                    .foregroundColor(.primary)

                Spacer()
            }
        }
    }

    // MARK: - Preview

    #Preview("Open Buttons") {
        OpenPreivewView()
            .frame(minWidth: 800, minHeight: 700)
    }
#endif
