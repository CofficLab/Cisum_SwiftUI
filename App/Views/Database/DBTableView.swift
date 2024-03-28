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
            Table(of: AudioModel.self, selection: $selectedAudioModels, sortOrder: $sortOrder, columns: {
                // value 参数用于排序
                TableColumn("歌曲 \(dbManager.audios.count)", value: \.title, content: getTitleColumn)
                TableColumn("艺人", value: \.artist, content: getArtistColumn).defaultVisibility(geo.size.width >= 500 ? .visible : .hidden)
                TableColumn("专辑", value: \.albumName, content: getAlbumColumn).defaultVisibility(geo.size.width >= 700 ? .visible : .hidden)
            }, rows: getRows)
        }
        .onChange(of: sortOrder) {
            dbManager.audios.sort(using: sortOrder)
        }
    }

    // MARK: 右键菜单

    private func getContextMenuItems(_ audio: AudioModel) -> some View {
        let selected: Set<AudioModel.ID> = selectedAudioModels

        return VStack {
            BtnPlay(audio: audio)

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

        // 如果在这里定义了tap事件，会影响table的单击选择功能
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
            TableRow(audio)
                .itemProvider { // enable Drap
                    NSItemProvider(object: audio.getURL() as NSItemProviderWriting)
                }
                .contextMenu {
                    getContextMenuItems(audio)
                }
        }
    }

    init() {
        os_log("🚩 DBTableView::Init")
    }
}

#Preview("APP") {
    RootView {
        ContentView()
    }
}
