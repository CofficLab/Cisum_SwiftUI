import MagicKit
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
struct AudioList: View, SuperThread, SuperLog, SuperEvent {
    let emoji = "📬"

    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var man: PlayMan
    @EnvironmentObject var db: AudioDB
    @EnvironmentObject var audioManager: AudioProvider

    @State var assets: [PlayAsset] = []
    @State var selection: URL? = nil
    @State var isSorting = false
    @State var sortMode: SortMode = .none
    @State var loading = true

    var total: Int { assets.count }

    init(verbose: Bool, reason: String) {
        if verbose {
            os_log("\(Logger.initLog)AudioList 🐛 \(reason)")
        }
    }

    var body: some View {
        Group {
            if loading {
                ProgressView()
            } else if isSorting {
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
                        ForEach(assets, id: \.url) { a in
                            AudioTile(asset: a)
                                .tag(a.url as URL?)
                        }
                    })
                }
                .listStyle(.plain)
            }
        }
        .onAppear(perform: handleOnAppear)
        .onChange(of: selection, handleSelectionChange)
        .onChange(of: man.asset, handlePlayAssetChange)
        .onReceive(nc.publisher(for: .PlayManStateChange), perform: handlePlayManStateChange)
        .onReceive(nc.publisher(for: .audioDeleted), perform: handleAudioDeleted)
        .onReceive(nc.publisher(for: .DBSorting), perform: onSorting)
        .onReceive(nc.publisher(for: .DBSortDone), perform: onSortDone)
    }

    private func refreshAssets() {
        Task.detached(priority: .background) {
            let audios = await db.allAudios(reason: self.className + ".handleAudioDeleted")
            let assets = audios.map { $0.toPlayAsset() }
            
            await MainActor.run {
                self.assets = assets
                self.loading = false
            }
        }
    }
}

// MARK: Event Handler

extension AudioList {
    func handleAudioDeleted(_ notification: Notification) {
        refreshAssets()
    }

    func handleOnAppear() {
        if let asset = man.asset {
            selection = asset.url
        }

        refreshAssets()
    }

    func handlePlayManStateChange(_ notification: Notification) {
        if let asset = man.asset, asset.url != self.selection {
            selection = asset.url
        }
    }

    func handleSelectionChange() {
        guard let url = selection, let asset = assets.first(where: { $0.url == url }) else {
            return
        }

        if url != man.asset?.url {
            self.man.play(asset, reason: self.className + ".SelectionChange", verbose: true)
        }
    }

    func handlePlayAssetChange() {
        if let asset = man.asset {
            selection = asset.url
        }
    }

    func onSorting(_ notification: Notification) {
        os_log("\(t)onSorting")
        isSorting = true
        if let mode = notification.userInfo?["mode"] as? String {
            sortMode = SortMode(rawValue: mode) ?? .none
        }
    }

    func onSortDone(_ notification: Notification) {
        os_log("\(t)onSortDone")

        self.refreshAssets()

        self.main.asyncAfter(deadline: .now() + 1.0) {
            isSorting = false
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

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}

#Preview {
    LayoutView(width: 400, height: 800)
        .frame(height: 800)
}
