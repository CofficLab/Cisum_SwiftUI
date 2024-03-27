import Foundation
import OSLog
import SwiftUI
import UniformTypeIdentifiers

struct DBTableView: View {
    @EnvironmentObject var dbManager: DBManager
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var appManager: AppManager

    @State private var selectedAudioModel: AudioModel? = nil
    @State private var selectedAudioModels = Set<AudioModel.ID>()
    @State private var sortOrder = [KeyPathComparator(\AudioModel.title)]

    var db: DBModel { dbManager.dbModel }

    var body: some View {
        GeometryReader { geo in
            Table(dbManager.audios, selection: $selectedAudioModels, sortOrder: $sortOrder) {
                TableColumn("歌曲 \(dbManager.audios.count)") { getTitleColumn($0) }
                TableColumn("艺人") { getArtistColumn($0) }.defaultVisibility(geo.size.width >= 500 ? .visible : .hidden)
                TableColumn("专辑") { getAlbumColumn($0) }.defaultVisibility(geo.size.width >= 700 ? .visible : .hidden)
            }
        }
        .onChange(of: sortOrder) {
            dbManager.audios.sort(using: sortOrder)
        }
        .contextMenu {
            getContextMenuItems()
        }
    }

    // MARK: 右键菜单

    private func getContextMenuItems(_ audio: AudioModel? = nil) -> some View {
        var selected: Set<AudioModel.ID> = selectedAudioModels
        var firstAudio = AudioModel.empty
        if audio != nil {
            selected.insert(audio!.id)
        }

        if let firstURL = selected.first {
            firstAudio = AudioModel(firstURL)
        }

        return VStack {
            BtnPlay(audio: firstAudio)
                .disabled(selected.count != 1)

            ButtonDownload(url: selected.first ?? AudioModel.empty.id)
                .disabled(selected.count != 1)

            #if os(macOS)
                BtnShowInFinder(url: selected.first ?? AudioModel.empty.id)
                    .disabled(selected.count != 1)
            #endif

            Divider()
//            ButtonAdd()
            ButtonCancelSelected(action: {
                selectedAudioModels.removeAll()
            }).disabled(selected.count == 0)

            Divider()

            // MARK: 删除

            ButtonDeleteSelected(audios: selected, callback: {
                selectedAudioModels = []
            }).disabled(selected.count == 0)
            // BtnDestroy()
        }
    }

    // MARK: 歌曲的第1列

    private func getTitleColumn(_ audio: AudioModel) -> some View {
        HStack {
            audio.getCover()
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .border(audioManager.audio == audio ? .clear : .clear)
            Text(audio.title).foregroundStyle(audioManager.audio == audio && !selectedAudioModels.contains(audio.id) ? .blue : .primary)
            Spacer()
        }
    }

    // MARK: 歌曲的第2列

    private func getArtistColumn(_ audio: AudioModel) -> some View {
        HStack {
            Text(audio.artist).foregroundStyle(audioManager.audio == audio && !selectedAudioModels.contains(audio.id) ? .blue : .primary)
            Spacer()
        }
    }

    // MARK: 歌曲的第3列

    private func getAlbumColumn(_ audio: AudioModel) -> some View {
        Text(audio.albumName).foregroundStyle(audioManager.audio == audio && !selectedAudioModels.contains(audio.id) ? .blue : .primary)
    }

    // MARK: 行

    private func getRows() -> some TableRowContent<AudioModel> {
        ForEach(dbManager.audios) { audio in
            if !selectedAudioModels.contains([audio.id]) || (selectedAudioModels.contains([audio.id]) && selectedAudioModels.count == 1) {
                TableRow(audio)
                    .itemProvider { // enable Drap
                        NSItemProvider(object: audio.getURL() as NSItemProviderWriting)
                    }
                    .contextMenu {
                        getContextMenuItems(audio)
                    }
            } else {
                TableRow(audio)
            }
        }
    }

    init() {
        os_log("🚩 DBTableView::Init")
    }
}

#Preview("APP") {
    RootView {
        ContentView(play: false)
    }
}
