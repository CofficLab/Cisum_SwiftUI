import CisumUIComponents
import SwiftUI

/// 音频仓库设置页：展示音频库文件列表。
///
/// 复用 `AudioListViewModel` 作为数据源，以列表形式展示音频库内容
/// （分页加载 + 总数统计），供用户在设置窗口中查看。
struct AudioDBSettingView: View {
    @EnvironmentObject var viewModel: AudioListViewModel
    @LumiTheme private var theme

    var body: some View {
        AppSettingsContentScaffold(scrollsContent: false, maxContentWidth: nil) {
            VStack(alignment: .leading, spacing: 12) {
                header

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
            Text("Audio Repository", bundle: .module)
                .font(.appTitle)
            Spacer()
            Text("Total \(viewModel.totalCount.description)", bundle: .module)
                .font(.appCaption)
                .foregroundStyle(.secondary)
        }
    }

    private var list: some View {
        List {
            if viewModel.isLoading && viewModel.urls.isEmpty {
                HStack {
                    Spacer()
                    ProgressView()
                        .controlSize(.small)
                    Spacer()
                }
                .listRowBackground(Color.clear)
            } else if viewModel.urls.isEmpty && !viewModel.isLoading {
                Text("Music repository is empty", bundle: .module)
                    .font(.appBody)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 40)
                    .listRowBackground(Color.clear)
            } else {
                ForEach(Array(viewModel.urls.enumerated()), id: \.element) { index, url in
                    row(url: url)
                        .listRowBackground(Color.clear)
                        .onAppear {
                            // 接近阈值时预取下一页（对齐 AudioList 行为）。
                            if AudioListLoadPolicy.isNearThreshold(
                                currentIndex: index,
                                loadedCount: viewModel.urls.count
                            ) {
                                viewModel.checkLoadMore(at: index)
                            }
                        }
                }
            }

            if viewModel.isLoadingMore && !viewModel.urls.isEmpty {
                HStack {
                    Spacer()
                    ProgressView()
                        .controlSize(.small)
                    Spacer()
                }
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(theme.background.ignoresSafeArea())
    }

    private func row(url: URL) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "music.note")
                .foregroundStyle(theme.primary)
                .frame(width: 18)
            Text(url.deletingPathExtension().lastPathComponent)
                .lineLimit(1)
            Spacer()
        }
        .padding(.vertical, 2)
    }
}
