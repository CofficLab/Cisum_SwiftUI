import CisumKernel
import SwiftUI

/// 内容 Tab 容器。
///
/// 插件存在时展示插件 Tab；插件尚未注入时展示可交互的 Mock 媒体库。
struct AppTabView: View {
    let kernel: CisumKernel
    @ObservedObject var model: MockPlayerModel
    @State private var selectedTab = 0

    private let mockTabs = ["音频库", "最近播放", "收藏"]

    private var pluginTabs: [(view: AnyView, label: String)] {
        kernel.plugin?.getTabViews(
            reason: "AppTabView",
            demoMode: kernel.appState?.isDemoMode ?? true
        ) ?? []
    }

    var body: some View {
        VStack(spacing: 0) {
            tabBar
            Divider()
            tabContent
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.background.secondary)
    }

    private var tabBar: some View {
        HStack(spacing: 4) {
            if pluginTabs.isEmpty {
                ForEach(Array(mockTabs.enumerated()), id: \.offset) { index, title in
                    TabButton(
                        title: title,
                        icon: index == 0 ? "music.note.list" : index == 1 ? "clock" : "heart",
                        isSelected: selectedTab == index
                    ) {
                        withAnimation(.easeInOut(duration: 0.16)) {
                            selectedTab = index
                        }
                    }
                }
            } else {
                ForEach(Array(pluginTabs.enumerated()), id: \.offset) { index, tab in
                    TabButton(title: tab.label, icon: "music.note", isSelected: selectedTab == index) {
                        selectedTab = index
                    }
                }
            }
            Spacer()
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background(.background)
    }

    @ViewBuilder
    private var tabContent: some View {
        if pluginTabs.isEmpty {
            MockLibraryView(model: model, selection: selectedTab)
        } else if let tab = pluginTabs[safe: selectedTab] {
            tab.view
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

private struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.callout.weight(isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor.opacity(0.12) : .clear, in: Capsule())
        }
        .buttonStyle(.plain)
    }
}

private struct MockLibraryView: View {
    @ObservedObject var model: MockPlayerModel
    let selection: Int

    private var tracks: [MockPlayerModel.Track] { model.tracks }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                HStack {
                    Text(selection == 0 ? "我的媒体库" : selection == 1 ? "最近播放" : "我的收藏")
                        .font(.title3.weight(.semibold))
                    Spacer()
                    Text("\(tracks.count) 项")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)

                ForEach(tracks, id: \.id) { track in
                    Button {
                        model.play(track)
                    } label: {
                        HStack(spacing: 12) {
                            RoundedRectangle(cornerRadius: 9, style: .continuous)
                                .fill(track.color.gradient)
                                .frame(width: 44, height: 44)
                                .overlay {
                                    Image(systemName: track.icon)
                                        .foregroundStyle(.white.opacity(0.9))
                                }

                            VStack(alignment: .leading, spacing: 3) {
                                Text(track.title)
                                    .foregroundStyle(.primary)
                                    .lineLimit(1)
                                Text(track.artist)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            if model.title == track.title {
                                Image(systemName: model.isPlaying ? "waveform" : "pause")
                                    .foregroundStyle(Color.accentColor)
                            } else {
                                Text(track.length)
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 9)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

private extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
