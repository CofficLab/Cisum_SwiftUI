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
struct AudioVStack: View, SuperThread, SuperLog {
    let emoji = "📬"

    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var data: DataProvider
    @EnvironmentObject var playMan: PlayMan
    @Environment(\.modelContext) var modelContext

    @Query(Audio.descriptorNotFolder) var audios: [Audio]

    @State var selection: URL? = nil
    @State var isSyncing: Bool = false
    @State var syncingCount: Int = 0
    @State private var loadedAudios: [Audio] = []
    @State private var isLoading = false
    @State private var currentPage = 0
    let pageSize = 50

    var total: Int { audios.count }
    var loaded: Int { loadedAudios.count }
    var remaining: Int { total - loaded }

    var showTips: Bool {
        if app.isDropping {
            return true
        }

        return app.flashMessage.isEmpty && audios.count == 0
    }

    init(verbose: Bool = false, reason: String) {
        if verbose {
            os_log("\(Logger.initLog)AudioList")
        }
    }

    var header: some View {
        HStack {
            Text("共 \(total.description)")
            Spacer()
            if isSyncing {
                HStack {
                    Image(systemName: "arrow.triangle.2.circlepath")
                    Text("正在同步 \(syncingCount.description) 项")
                }
            }
            if Config.isNotDesktop {
                BtnAdd()
                    .font(.title2)
                    .labelStyle(.iconOnly)
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .font(.footnote)
        .background(.background)
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // header
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(loadedAudios, id: \.url) { audio in
                            VStack(spacing: 0) {
                                AudioTile(audio: audio)
                                    .tag(audio.url as URL?)
                                    .onTapGesture {
                                        selection = audio.url
                                    }
                                Divider()
                                    .background(Color.gray.opacity(0.3))
                                    .padding(.horizontal, 0)
                                    .padding(.bottom, 8)
                                    .padding(.top, 4)
                            }
                        }
                        if isLoading {
                            ProgressView().frame(height: 30)
                        }
                        if currentPage * pageSize < audios.count {
                            Text("加载更多... (剩余 \(remaining.description) 项)")
                                .frame(height: 50)
                                .onAppear {
                                    Task {
                                        await loadMoreAudios()
                                    }
                                }
                        }
                    }
                    .padding()
                }
            }

            if showTips {
                DBTips()
            }
        }
        .onAppear(perform: handleOnAppear)
        .onChange(of: selection, handleSelectionChange)
        .onReceive(NotificationCenter.default.publisher(for: .PlayManStateChange), perform: handlePlayManStateChange)
        .onReceive(NotificationCenter.default.publisher(for: .dbSyncing), perform: handleDBSyncing)
        .onReceive(NotificationCenter.default.publisher(for: .dbSynced), perform: handleDBSynced)
        .task {
            await loadInitialAudios()
        }
    }
}

// MARK: Event Handler

extension AudioVStack {
    func handleOnAppear() {
        if let asset = playMan.asset {
            selection = asset.url
        }
    }

    func handlePlayManStateChange(_ notification: Notification) {
        self.bg.async {
            if let asset = playMan.asset, asset.url != self.selection {
                selection = asset.url
            }
        }
    }

    func handleDBSyncing(_ notification: Notification) {
        isSyncing = true
        if let files = notification.object as? [DiskFile] {
            syncingCount = files.count
        }
    }

    func handleDBSynced(_ notification: Notification) {
        isSyncing = false
    }

    func handleSelectionChange() {
        guard let url = selection, let audio = audios.first(where: { $0.url == url }) else {
            return
        }

        self.bg.async {
            if url != playMan.asset?.url {
                self.playMan.play(audio.toPlayAsset(), reason: "AudioList SelectionChange")
            }
        }
    }
}

// MARK: Data Loading

extension AudioVStack {
    func loadInitialAudios() async {
        isLoading = true
        defer { isLoading = false }

        let endIndex = min(pageSize, audios.count)
        let initialBatch = Array(audios[0 ..< endIndex])

        await MainActor.run {
            loadedAudios = initialBatch
            currentPage = 1
        }
    }

    func loadMoreAudios() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        let startIndex = currentPage * pageSize
        let endIndex = min(startIndex + pageSize, audios.count)
        let nextBatch = Array(audios[startIndex ..< endIndex])

        await MainActor.run {
            loadedAudios.append(contentsOf: nextBatch)
            currentPage += 1
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
