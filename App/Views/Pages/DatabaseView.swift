import Foundation
import OSLog
import SwiftUI
import UniformTypeIdentifiers

struct DatabaseView: View {
    @EnvironmentObject var databaseManager: DatabaseManager
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var appManager: AppManager

    @State private var selectedAudioModel: AudioModel? = nil
    @State private var selectedAudioModels = Set<AudioModel.ID>()
    @State private var sortOrder = [KeyPathComparator(\AudioModel.title)]
    @State private var dropping: Bool = false

    var body: some View {
        #if os(iOS)
            NavigationView {
                ZStack {
                    if databaseManager.isEmpty {
                        BackgroundView.type1
                        EmptyDatabaseView()
                    } else {
                        table
                    }
                }
                .toolbar {
                    ButtonAdd()
                }
            }
            .fileImporter(
                isPresented: $appManager.isImporting,
                allowedContentTypes: [.audio],
                allowsMultipleSelection: true,
                onCompletion: { result in
                    switch result {
                    case let .success(urls):
                        databaseManager.add(urls, completionAll: {
                            appManager.setFlashMessage("添加成功")
                        })
                    case let .failure(error):
                        print("导入文件失败Error: \(error)")
                    }
                })
        #else
        ZStack {
            table

            // 仓库为空
            if databaseManager.isEmpty && appManager.flashMessage.isEmpty {
                EmptyDatabaseView()
            }
        }
        #endif
    }

    private var table: some View {
        tableView
            .onChange(of: dropping, perform: { v in
                appManager.setFlashMessage(v ? "松开可添加文件" : "")
            })
            .onDrop(of: [UTType.fileURL], isTargeted: $dropping) { providers -> Bool in
                let dispatchGroup = DispatchGroup()
                var dropedFiles: [URL] = []
                for provider in providers {
                    dispatchGroup.enter()
                    // 这是异步操作
                    _ = provider.loadObject(ofClass: URL.self) { object, _ in
                        if let url = object {
                            // AppConfig.logger.ui.debug("添加 \(url.lastPathComponent, privacy: .public)")
                            dropedFiles.append(url)
                        }

                        dispatchGroup.leave()
                    }
                }

                dispatchGroup.notify(queue: .main) {
                    // 等待所有异步操作完成
                    AppConfig.logger.ui.debug("Drop 了 \(dropedFiles.count) 个文件")

                    appManager.stateMessage = "正在复制 \(dropedFiles.count) 个文件"
                    databaseManager.add(
                        dropedFiles,
                        completionAll: {
                            appManager.setFlashMessage("拖动的文件已添加")
                            appManager.stateMessage = ""
                        },
                        completionOne: { url in
                            appManager.setFlashMessage("已添加 \(url.lastPathComponent)")
                        }
                    )
                }

                return true
            }
            .onChange(of: sortOrder) { newOrder in
                databaseManager.audios.sort(using: newOrder)
            }
            .contextMenu {
                getContextMenuItems()
            }
    }

    private var tableView: some View {
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
        }
    }

    private func getTitleColumn(_ audio: AudioModel) -> some View {
        HStack {
            if audio == audioManager.audio {
                Image(systemName: "signpost.right").frame(width: 16)
            } else {
                audio.getIcon()
            }

            AlbumView(audio: Binding.constant(audio)).frame(width: 24, height: 24)

            Text(audio.title)
        }
        .onTapGesture(count: 2, perform: { playNow(audio: audio) })
    }

    private func getRows() -> some TableRowContent<AudioModel> {
        ForEach(databaseManager.audios) { audio in
            if !selectedAudioModels.contains([audio.url]) || (selectedAudioModels.contains([audio.url]) && selectedAudioModels.count == 1) {
                TableRow(audio)
                    .itemProvider { // enable Drap
                        NSItemProvider(object: audio.url as NSItemProviderWriting)
                    }
                    .contextMenu {
                        getContextMenuItems(audio)
                    }
            } else {
                TableRow(audio)
            }
        }
    }

    private func playNow(audio: AudioModel) {
        if audio.isDownloading {
            appManager.alertMessage = "正在下载，不能播放"
            appManager.showAlert = true
        } else {
            audioManager.playFile(url: audio.url)
        }
    }

    private func getContextMenuItems(_ audio: AudioModel? = nil) -> some View {
        var selected: Set<AudioModel.ID> = selectedAudioModels
        if audio != nil {
            selected.insert(audio!.id)
        }

        return VStack {
            ButtonPlay(url: selected.first ?? emptyAudioModel.id)
                .disabled(selected.count != 1)

            ButtonDownload(url: selected.first ?? emptyAudioModel.id)
                .disabled(selected.count != 1)

            #if DEBUG && os(macOS)
                ButtonShowInFinder(url: selected.first ?? emptyAudioModel.id)
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
        }
    }
}

#Preview {
    RootView {
        DatabaseView()
    }
}

#Preview {
    RootView {
        DatabaseView().frame(width: 300)
    }
}

#Preview {
    RootView {
        DatabaseView().frame(width: 350)
    }
}

#Preview {
    RootView {
        DatabaseView().frame(width: 400)
    }
}

#Preview {
    RootView {
        DatabaseView().frame(width: 500)
    }
}

#Preview {
    RootView {
        DatabaseView().frame(width: 600)
    }
}
