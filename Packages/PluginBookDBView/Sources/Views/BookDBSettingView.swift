import CisumUIComponents
import PluginBook
import SwiftUI

/// 有声书仓库设置页：展示书籍库列表。
///
/// 复用 `BookListViewModel` 作为数据源，以列表形式展示有声书仓库内容
/// （书籍标题 + 子章节数 + 总数统计），供用户在设置窗口中查看。
/// 右上角提供「打开仓库根目录」按钮，在 Finder 中打开有声书仓库目录。
///
/// 布局统一使用 LumiUI 组件（`AppSettingsContentScaffold` /
/// `AppSettingSection` / `AppSettingRow` / `AppButton` / `AppEmptyState`）。
struct BookDBSettingView: View {
    @EnvironmentObject var viewModel: BookListViewModel
    @LumiTheme private var theme

    var body: some View {
        AppSettingsContentScaffold(scrollsContent: false, maxContentWidth: nil) {
            VStack(alignment: .leading, spacing: 16) {
                header

                repositoryPathSection

                list
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .strokeBorder(theme.divider, lineWidth: 1)
                    }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .onAppear {
            viewModel.handleOnAppear()
        }
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Audiobook Repository", bundle: .module)
                .font(.appTitle)
            Spacer()
            Text("Total \(viewModel.totalCount.description)", bundle: .module)
                .font(.appCaption)
                .foregroundStyle(.secondary)
            #if os(macOS)
            openDirectoryButton
            #endif
        }
    }

    // MARK: - 仓库路径（LumiUI 设置卡片）

    /// 以 LumiUI 设置卡片展示有声书仓库根目录路径（与「打开仓库根目录」按钮共用
    /// `BookPlugin.getBookDisk()`），路径可选中复制；仓库不可用时显示占位文案。
    @MainActor
    private var repositoryPathSection: some View {
        let disk = BookPlugin.getBookDisk()
        return AppSettingSection(title: String(localized: "Repository Path", bundle: .module)) {
            AppSettingRow(
                title: String(localized: "Repository path", bundle: .module),
                description: String(localized: "The root directory that stores all audiobook files", bundle: .module),
                icon: "folder"
            ) {
                if let disk {
                    Text(disk.path(percentEncoded: false))
                        .font(.appCaption)
                        .foregroundStyle(theme.primary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .textSelection(.enabled)
                        .help(Text(disk.path(percentEncoded: false)))
                } else {
                    Text("Unavailable", bundle: .module)
                        .font(.appCaption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - 打开仓库根目录

    #if os(macOS)
    /// 打开有声书仓库根目录（Finder 中显示该文件夹）；仓库目录不可用时按钮置灰。
    @MainActor
    private var openDirectoryButton: some View {
        let disk = BookPlugin.getBookDisk()
        return AppButton(
            String(localized: "Open repository folder", bundle: .module),
            systemImage: "folder",
            style: .secondary,
            size: .small
        ) {
            disk?.openFolder()
        }
        .disabled(disk == nil)
        .help(Text("Open repository folder", bundle: .module))
    }
    #endif

    private var list: some View {
        List {
            if viewModel.isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                        .controlSize(.small)
                    Spacer()
                }
                .listRowBackground(Color.clear)
            } else if viewModel.books.isEmpty {
                AppEmptyState(
                    icon: "book.closed",
                    title: String(localized: "Audiobook repository is empty", bundle: .module)
                )
                .listRowBackground(Color.clear)
            } else {
                ForEach(viewModel.books) { book in
                    row(book: book)
                        .listRowBackground(Color.clear)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(theme.background.ignoresSafeArea())
    }

    private func row(book: BookDTO) -> some View {
        HStack(spacing: 10) {
            Image(systemName: BookDBPluginInfo.iconName)
                .foregroundStyle(theme.primary)
                .frame(width: 18)
            Text(book.bookTitle)
                .lineLimit(1)
            Spacer()
            if book.childCount > 0 {
                Text(book.childCount.description)
                    .font(.appCaption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}
