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
struct AudioList: View, SuperThread, SuperLog {
    let emoji = "📬"

    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var data: DataProvider
    @EnvironmentObject var playMan: PlayMan
    @EnvironmentObject var messageManager: MessageProvider
    @Environment(\.modelContext) var modelContext

    @Query(Audio.descriptorNotFolder) var audios: [Audio]

    @State var selection: URL? = nil
    @State var isSyncing: Bool = false

    var total: Int { audios.count }

    var showTips: Bool {
        if app.isDropping {
            return true
        }

        return messageManager.flashMessage.isEmpty && audios.count == 0
    }

    init(verbose: Bool = false, reason: String) {
        if verbose {
            os_log("\(Logger.initLog)AudioList")
        }
    }

    var body: some View {
        ZStack {
            List(selection: $selection) {
                Section(header: HStack {
                    Text("共 \(total.description)")
                    Spacer()
                    if isSyncing {
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
                    ForEach(audios, id: \.url) { audio in
                        AudioTile(audio: audio)
                            .tag(audio.url as URL?)
                    }
                })
            }

            if showTips {
                DBTips()
            }
        }
        .onAppear(perform: handleOnAppear)
        .onChange(of: selection, handleSelectionChange)
        .onChange(of: playMan.asset, handlePlayAssetChange)
        .onReceive(NotificationCenter.default.publisher(for: .PlayManStateChange), perform: handlePlayManStateChange)
        .onReceive(NotificationCenter.default.publisher(for: .dbSyncing), perform: handleDBSyncing)
        .onReceive(NotificationCenter.default.publisher(for: .dbSynced), perform: handleDBSynced)
    }
}

// MARK: Event Handler

extension AudioList {
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
        guard let group = notification.userInfo?["group"] as? DiskFileGroup else {
            return
        }

        if group.isFullLoad {
            isSyncing = false
        } else {
            isSyncing = true
        }
    }

    func handleDBSynced(_ notification: Notification) {
        isSyncing = false
    }

    func handleSelectionChange() {
        guard let url = selection, let audio = audios.first(where: { $0.url == url }) else {
            return
        }

        if url != playMan.asset?.url {
            do {
                try self.playMan.play(audio.toPlayAsset(), reason: "AudioList SelectionChange", verbose: true)
            } catch let e {
                os_log("\(self.t)handleSelectionChange error: \(e)")
                self.messageManager.alert(e.localizedDescription)
            }
        }
    }

    func handlePlayAssetChange() {
        if let asset = playMan.asset, let audio = audios.first(where: { $0.url == asset.url }) {
            selection = asset.url
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
