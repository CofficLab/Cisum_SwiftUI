import MagicCore

import OSLog
import SwiftData
import SwiftUI

/*
 将仓库中的文件扁平化展示，文件夹将被忽略
    A
      A1               A1
      A2               A2
    B           =>     B1
      B1               B2
      B2
 */
struct AudioList2: View, SuperThread, SuperLog, SuperEvent {
    nonisolated static let emoji = "📬"

    @Environment(\.modelContext) private var modelContext

    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var man: PlayMan
    @EnvironmentObject var audioManager: AudioProvider
    @EnvironmentObject var audioDB: AudioDB
    @EnvironmentObject var m: MessageProvider

    @State var selection: URL? = nil
    @State var isSorting = false
    @State var sortMode: SortMode = .none

    @Query(sort: \AudioModel.order, animation: .default) var audios: [AudioModel]

    var total: Int { urls.count }
    var urls: [URL] { audios.map({ $0.url }) }

    var body: some View {
        Group {
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
                        if audioManager.isSyncing {
                            HStack {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                Text("正在读取仓库")
                            }
                        }

                        if Config.isNotDesktop {
                            BtnAdd()
                                .font(.title2)
                                .labelStyle(.iconOnly)
                        }
                    }, content: {
                        ForEach(urls, id: \.self) { url in
                            AudioItemView(url: url)
                        }
                        .onDelete(perform: deleteItems)
                    })
                }
                .listStyle(.plain)
            }
        }
        .onAppear(perform: handleOnAppear)
        .onChange(of: selection, handleSelectionChange)
        .onChange(of: man.asset, handlePlayAssetChange)
        .onReceive(nc.publisher(for: .DBSorting), perform: onSorting)
        .onReceive(nc.publisher(for: .DBSortDone), perform: onSortDone)
    }
}

// MARK: Event Handler

extension AudioList2 {
    func handleOnAppear() {
        if let asset = man.asset {
            setSelection(asset)
        }
    }

    func handleSelectionChange() {
        guard let url = selection, urls.contains(url) else {
            return
        }

        if url != man.asset {
            Task {
                await self.man.play(url: url)
            }
        }
    }

    func handlePlayAssetChange() {
        if let asset = man.asset {
            setSelection(asset)
        }
    }

    func onSorting(_ notification: Notification) {
        os_log("\(t)onSorting")
        setIsSorting(true)
        if let mode = notification.userInfo?["mode"] as? String {
            setSortMode(SortMode(rawValue: mode) ?? .none)
        }
    }

    func onSortDone(_ notification: Notification) {
        os_log("\(t)onSortDone")
//        self.updateURLs()
    }

    func deleteItems(at offsets: IndexSet) {
        withAnimation {
            // 获取要删除的 URLs
            let urlsToDelete = offsets.map { urls[$0] }
            
            // 从数据库中删除对应的 AudioModel
            for url in urlsToDelete {
                os_log("\(t)deleteItems: \(url.shortPath())")
                do {
                    try url.delete()

                    m.toast("已删除 \(url.title)")
                } catch {
                    os_log(.error, "\(t)deleteItems: \(error)")

                    m.error(error)
                }
            }
        }
    }
}

extension AudioList2 {
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

extension AudioList2 {
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

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}

#Preview {
    LayoutView(width: 400, height: 800)
        .frame(height: 800)
}
