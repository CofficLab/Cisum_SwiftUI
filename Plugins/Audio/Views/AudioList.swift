import MagicCore

import OSLog
import SwiftData
import SwiftUI

/*
 展示策略（扁平化列表）：
 - 仅展示仓库中的音频文件；文件夹不会作为分组出现
 - 所有子目录中的文件被“拍平”后按统一规则排序与展示

 示例：
   根目录
   ├─ A/
   │  ├─ A1
   │  └─ A2
   └─ B/
      ├─ B1
      └─ B2

   扁平化后展示为：A1、A2、B1、B2（不显示 A、B 目录本身）
 */
struct AudioList: View, SuperThread, SuperLog, SuperEvent {
    nonisolated static let emoji = "📬"

    @EnvironmentObject var playManController: PlayManController
    @EnvironmentObject var audioProvider: AudioProvider
    @EnvironmentObject var m: MagicMessageProvider

    @State var selection: URL? = nil
    @State var isSorting = false
    @State var sortMode: SortMode = .none
    @State var urls: [URL] = []
    @State private var isSyncing: Bool = false

    var total: Int { urls.count }

    var body: some View {
        os_log("\(self.t)开始渲染")
        return Group {
            if isSorting {
                VStack(spacing: 0) {
                    Spacer()

                    Image(systemName: sortMode.icon)
                        .font(.system(size: 40))
                        .foregroundStyle(.tint)
                        .rotationEffect(.degrees(360))
                        .animation(.linear(duration: 2).repeatForever(autoreverses: false), value: isSorting)

                    Text(sortMode.description)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .padding(.top, 24)

                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if total == 0 {
                AudioDBTips()
            } else {
                List(selection: $selection) {
                    Section(header: HStack {
                        Text("共 \(total.description)")
                        Spacer()
                        if isSyncing {
                            HStack(spacing: 6) {
                                ProgressView()
                                    .controlSize(.small)
                                Text("正在读取仓库")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        if Config.isNotDesktop {
                            BtnAdd()
                                .font(.title2)
                                .labelStyle(.iconOnly)
                        }
                    }, content: {
                        ForEach(urls, id: \.self) { url in
                            AudioItemView(url)
                        }
                        .onDelete(perform: onDeleteItems)
                    })
                }
                .listStyle(.plain)
            }
        }
        .onAppear(perform: handleOnAppear)
        .onChange(of: selection, handleSelectionChange)
        .onReceive(nc.publisher(for: .DBSorting), perform: onSorting)
        .onReceive(nc.publisher(for: .DBSortDone), perform: onSortDone)
        .onReceive(nc.publisher(for: .dbDeleted), perform: onDeleted)
        .onReceive(nc.publisher(for: .dbSynced), perform: onSynced)
        .onReceive(nc.publisher(for: .dbUpdated), perform: onUpdated)
        .onReceive(nc.publisher(for: .dbSyncing), perform: onSyncing)
        .onReceive(nc.publisher(for: .dbSynced), perform: onSynced)
        .onPlayManAssetChanged(handlePlayAssetChange)
    }
}

// MARK: - Action

extension AudioList {
    private func updateURLs() {
        Task.detached(priority: .background) {
            let urls = await audioProvider.db.allAudios(reason: self.className)

            await self.setUrls(urls)
        }
    }
}

// MARK: - Setter

extension AudioList {
    @MainActor
    private func setUrls(_ newValue: [URL]) {
        urls = newValue
    }

    private func setSelection(_ newValue: URL?) {
        selection = newValue
    }

    private func setIsSorting(_ newValue: Bool) {
        isSorting = newValue
    }

    private func setSortMode(_ newValue: SortMode) {
        sortMode = newValue
    }
}

// MARK: - Event Handler

extension AudioList {
    func handleOnAppear() {
        updateURLs()

        if let asset = playManController.getAsset() {
            setSelection(asset)
        }
    }

    func handleSelectionChange() {
        guard let url = selection, urls.contains(url) else {
            return
        }

        if url != playManController.getAsset() {
            Task {
                await self.playManController.play(url: url)
            }
        }
    }

    func handlePlayAssetChange(url: URL?) {
        if let asset = url {
            self.setSelection(asset)
        }
    }

    func onSorting(_ notification: Notification) {
        os_log("\(t)🍋 onSorting")
        setIsSorting(true)
        if let mode = notification.userInfo?["mode"] as? String {
            setSortMode(SortMode(rawValue: mode) ?? .none)
        }
    }

    func onSortDone(_ notification: Notification) {
        os_log("\(t)🍋 onSortDone")
        self.updateURLs()
    }

    func onDeleted(_ notification: Notification) {
        os_log("\(t)🍋 onDeleted")
        self.updateURLs()
    }

    func onSynced(_ notification: Notification) {
        os_log("\(t)🍋 onSynced")
        self.updateURLs()
        self.isSyncing = false
    }

    func onUpdated(_ notification: Notification) {
        os_log("\(t)🍋 onUpdated")
        self.updateURLs()
    }

    func onSyncing(_ notification: Notification) {
        os_log("\(t)🍋 onSyncing")
        self.isSyncing = true
    }

    func onDeleteItems(at offsets: IndexSet) {
        withAnimation {
            // 获取要删除的 URLs
            let urlsToDelete = offsets.map { urls[$0] }

            // 从数据库中删除对应的 AudioModel
            for url in urlsToDelete {
                os_log("\(t)deleteItems: \(url.shortPath())")
                do {
                    try url.delete()

                    m.info("已删除 \(url.title)")
                } catch {
                    os_log(.error, "\(t)deleteItems: \(error)")

                    m.error(error)
                }
            }
        }
    }
}

extension AudioList {
    enum SortMode: String {
        case random, order, none

        var icon: String {
            switch self {
            case .random: return "shuffle"
            case .order: return "arrow.up.arrow.down"
            case .none: return "arrow.triangle.2.circlepath"
            }
        }

        var description: String {
            switch self {
            case .random: return "正在随机排序..."
            case .order: return "正在顺序排序..."
            case .none: return "正在排序..."
            }
        }
    }
}

#Preview("Small Screen") {
    RootView {
        ContentView()
    }
    .frame(width: 500)
    .frame(height: 1200)
}

#Preview("Big Screen") {
    RootView {
        ContentView()
    }
    .frame(width: 1200)
    .frame(height: 1200)
}
