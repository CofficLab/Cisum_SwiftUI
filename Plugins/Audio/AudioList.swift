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
    @EnvironmentObject var playMan: PlayMan
    @EnvironmentObject var db: AudioDB
    @EnvironmentObject var audioManager: AudioProvider

    @State var audios: [AudioModel] = []
    @State var selection: URL? = nil

    var total: Int { audios.count }

    init(verbose: Bool, reason: String) {
        if verbose {
            os_log("\(Logger.initLog)AudioList 🐛 \(reason)")
        }
    }

    var body: some View {
        List(audios, id: \.url, selection: $selection) { audio in
            AudioTile(audio: audio)
                .tag(audio.url as URL?)
        }
        .listStyle(.plain)
        .onAppear(perform: handleOnAppear)
        .onChange(of: selection, handleSelectionChange)
        .onChange(of: playMan.asset, handlePlayAssetChange)
        .onReceive(nc.publisher(for: .PlayManStateChange), perform: handlePlayManStateChange)
        .onReceive(nc.publisher(for: .audioDeleted), perform: handleAudioDeleted)
    }
}

// MARK: Event Handler

extension AudioList {
    func handleAudioDeleted(_ notification: Notification) {
        Task {
            self.audios = await db.allAudios(reason: self.className + ".handleAudioDeleted")
        }
    }

    func handleOnAppear() {
        if let asset = playMan.asset {
            selection = asset.url
        }

        Task {
            self.audios = await db.db.allAudios(reason: self.className + ".handleOnAppear")
        }
    }

    func handlePlayManStateChange(_ notification: Notification) {
        if let asset = playMan.asset, asset.url != self.selection {
            selection = asset.url
        }
    }

    func handleSelectionChange() {
        guard let url = selection, let audio = audios.first(where: { $0.url == url }) else {
            return
        }

        if url != playMan.asset?.url {
            self.playMan.play(audio.toPlayAsset(), reason: self.className + ".SelectionChange", verbose: true)
        }
    }

    func handlePlayAssetChange() {
        if let asset = playMan.asset {
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
