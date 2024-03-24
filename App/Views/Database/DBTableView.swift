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
            VStack(spacing: 0) {
                if geo.size.width <= 500 {
                    // 一列模式
                    Table(of: AudioModel.self, selection: $selectedAudioModels, sortOrder: $sortOrder, columns: {
                        TableColumn("歌曲", value: \.title, content: getTitleColumn)
                    }, rows: getRows)
                } else if geo.size.width <= 700 {
                    // 两列模式
                    Table(of: AudioModel.self, selection: $selectedAudioModels, sortOrder: $sortOrder, columns: {
                        TableColumn("歌曲", value: \.title, content: getTitleColumn)
                        TableColumn("艺人", value: \.artist)
                    }, rows: getRows)
                } else {
                    // 三列模式
                    Table(of: AudioModel.self, selection: $selectedAudioModels, sortOrder: $sortOrder, columns: {
                        TableColumn("歌曲", value: \.title, content: getTitleColumn)
                        TableColumn("艺人", value: \.artist)
                        TableColumn("专辑", value: \.albumName)
                    }, rows: getRows)
                }
            }
        }.onChange(of: sortOrder) { newOrder in
            dbManager.audios.sort(using: newOrder)
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
            ButtonAdd()
            ButtonCancelSelected(action: {
                selectedAudioModels.removeAll()
            }).disabled(selected.count == 0)

            Divider()
            ButtonDeleteSelected(audios: selected, callback: {
                selectedAudioModels = []
            }).disabled(selected.count == 0)
            BtnDestroy()
        }
    }

    private func playNow(_ audio: AudioModel) {
        if audio.isDownloading {
            appManager.alertMessage = "正在下载，不能播放"
            appManager.showAlert = true
        } else {
            audioManager.play(audio)
        }
    }

    // MARK: 歌曲的主要信息
    
    private func getTitleColumn(_ audio: AudioModel) -> some View {
        HStack {
            audio.getIcon()

            AlbumView(audio: Binding.constant(audio)).frame(width: 24, height: 24)

            DBTitle(audio: audio)
        }
        // MARK: 双击播放
        .onTapGesture(count: 2, perform: {
            playNow(audio)
        })
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
}

#Preview("APP") {
    RootView {
        ContentView(play: false)
    }
}
