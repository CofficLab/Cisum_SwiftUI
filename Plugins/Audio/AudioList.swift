import MagicKit
import MagicUI
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
    static let emoji = "📬"

    @Environment(\.modelContext) private var modelContext

    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var man: PlayMan
    @EnvironmentObject var audioManager: AudioProvider
    @EnvironmentObject var audioDB: AudioDB

    @State var selection: URL? = nil
    @State var isSorting = false
    @State var sortMode: SortMode = .none

    @Query(sort: \AudioModel.order, animation: .default) var audios: [AudioModel]

    var total: Int { audios.count }
    var assets: [PlayAsset] { audios.map { $0.toPlayAsset(delegate: audioDB) } }

    init(verbose: Bool, reason: String) {
        if verbose {
            os_log("\(Self.i)AudioList 🐛 \(reason)")
        }
    }

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
}

// MARK: Event Handler

extension AudioList {
    func handleAudioDeleted(_ notification: Notification) {
    }

    func handleOnAppear() {
        if let asset = man.asset {
            selection = asset.url
        }
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
