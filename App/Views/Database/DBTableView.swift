import Foundation
import OSLog
import SwiftUI
import UniformTypeIdentifiers

struct DBTableView: View {
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var appManager: AppManager

    @State private var selections = Set<Audio.ID>()
    @State private var sortOrder = [KeyPathComparator(\Audio.title)]

    var db: DB { audioManager.db }
    var audios: [Audio] { audioManager.audios }
    var downloaded: [Audio] { audios.filter { $0.isDownloaded } }
    var description: String {
        if downloaded.count == audios.count {
            return "歌曲"
        }
        
        return "歌曲 \(downloaded.count)/\(audios.count) 已下载 "
    }

    var body: some View {
        GeometryReader { geo in
            Table(
                of: Audio.self, selection: $selections, sortOrder: $sortOrder,
                columns: {
                    // value 参数用于排序
                    TableColumn(description, value: \.title,
                        content: { audio in
                            HStack {
                                AlbumView(audio: audio, downloadingPercent: audio.downloadingPercent, withBackground: true,rotate: false)
                                    .frame(width: 24, height: 24)
                                Text(audio.title).foregroundStyle(audioManager.audio == audio ? .blue : .primary)
                                Spacer()
                                if audio.isDownloading {
                                    Text("\(String(format: "%.2f", audio.downloadingPercent))%").font(.footnote)
                                }
                            }
                        })
                    TableColumn("艺人", value: \.artist, content: getArtistColumn).defaultVisibility(
                        geo.size.width >= 500 ? .visible : .hidden)
                    TableColumn("专辑", value: \.albumName, content: getAlbumColumn).defaultVisibility(
                        geo.size.width >= 700 ? .visible : .hidden)
                    TableColumn("文件大小", value: \.size, content: getSizeColumn).defaultVisibility(
                        geo.size.width >= 700 ? .visible : .hidden)
                }, rows: getRows)
        }
        .onChange(of: sortOrder) {
            audioManager.audios.sort(using: sortOrder)
        }
    }

    // MARK: 右键菜单

    private func getContextMenuItems(_ audio: Audio) -> some View {
        let selected: Set<Audio.ID> = selections

        return VStack {
            BtnPlay(audio: audio)

            BtnDownload(audio: audio)

            #if os(macOS)
                BtnShowInFinder(url: audio.getURL())
            #endif

            Divider()
            //            ButtonAdd()
            ButtonCancelSelected(action: {
                selections.removeAll()
            }).disabled(selected.count == 0)

            Divider()

            // MARK: 删除

//            ButtonDeleteSelected(
//                audios: selected,
//                callback: {
//                    selectedAudioModels = []
//                }).disabled(selected.count == 0)
            // BtnDestroy()
        }
    }

    // MARK: 歌曲的第2列

    private func getArtistColumn(_ audio: Audio) -> some View {
        HStack {
            Text(audio.artist).foregroundStyle(
                audioManager.audio == audio && !selections.contains(audio.id) ? .blue : .primary)
            Spacer()
        }
    }

    // MARK: 歌曲的第3列

    private func getAlbumColumn(_ audio: Audio) -> some View {
        Text(audio.albumName).foregroundStyle(
            audioManager.audio == audio && !selections.contains(audio.id) ? .blue : .primary)
    }

    // MARK: 歌曲的第4列

    private func getSizeColumn(_ audio: Audio) -> some View {
        Text(audio.getFileSizeReadable()).foregroundStyle(
            audioManager.audio == audio && !selections.contains(audio.id) ? .blue : .primary)
    }

    // MARK: 行

    private func getRows() -> some TableRowContent<Audio> {
        return ForEach(audios) { audio in
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
        // os_log("\(Logger.isMain)🚩 DBTableView::Init")
    }
}

#Preview("APP") {
    RootView {
        ContentView()
    }.frame(width: 700)
}

#Preview("APP") {
    RootView {
        ContentView()
    }.frame(width: 350)
}
