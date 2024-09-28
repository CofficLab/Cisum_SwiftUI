import Foundation
import OSLog
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct AudioDB: View {
    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var data: DataProvider
    @EnvironmentObject var db: DB

    @State private var treeView = false
    @State private var isSorting = false
    @State private var sortMode: SortMode = .none
    @State private var isDropping: Bool = false

    @Query(Audio.descriptorAll, animation: .default) var audios: [Audio]

    static let label = "🐘 DBLayout::"

    private var main = Config.mainQueue
    private var bg = Config.bgQueue
    private var disk: any Disk { data.disk }
    private var label: String { "\(Logger.isMain)\(Self.label) " }

    var showTips: Bool {
        if isDropping {
            return true
        }

        return app.flashMessage.isEmpty && audios.count == 0
    }

    init(verbose: Bool = false) {
        if verbose {
            os_log("\(Logger.isMain)\(Self.label)初始化")
        }
    }

    var body: some View {
        ZStack {
            VStack {
                if isSorting {
                    Text(sortMode.description)
                } else {
                    AudioVStack(reason: "AudioDB")
                        .frame(maxHeight: .infinity)
                }

                AudioTask()
                    .shadow(radius: 10)
            }

            if showTips {
                DBTips()
            }
        }
        .fileImporter(
            isPresented: $app.isImporting,
            allowedContentTypes: [.audio],
            allowsMultipleSelection: true,
            onCompletion: handleFileImport
        )
        .onReceive(NotificationCenter.default.publisher(for: .DBSorting), perform: onSorting)
        .onReceive(NotificationCenter.default.publisher(for: .DBSortDone), perform: onSortDone)
        .onDrop(of: [UTType.fileURL], isTargeted: self.$isDropping, perform: onDrop)
    }
}

// MARK: - Enums

extension AudioDB {
    enum SortMode: String {
        case random, order, none

        var description: String {
            switch self {
            case .random: return "正在随机排序..."
            case .order: return "正在顺序排序..."
            case .none: return "正在排序..."
            }
        }
    }
}

// MARK: - Helper Methods

extension AudioDB {
    private func handleFileImport(result: Result<[URL], Error>) {
        switch result {
        case let .success(urls):
            emitCopyFiles(urls)
        case let .failure(error):
            os_log(.error, "导入文件失败Error: \(error.localizedDescription)")
        }
    }

    private func setFlashMessage(_ m: String) {
        main.async {
            app.setFlashMessage(m)
            self.cleanStateMessage()
        }
    }

    private func setStateMessage(_ m: String) {
        main.async {
            app.stateMessage = m
        }
    }

    private func cleanStateMessage() {
        main.async {
            app.cleanStateMessage()
        }
    }
}

// MARK: - Event Handlers

extension AudioDB {
    func onDrop(_ providers: [NSItemProvider]) -> Bool {
        bg.async {
            let dispatchGroup = DispatchGroup()
            var droppedFiles: [URL] = []

            for provider in providers {
                dispatchGroup.enter()
                provider.loadObject(ofClass: URL.self) { url, _ in
                    if let url = url {
                        os_log("\(Logger.isMain)🖥️ DBView::添加 \(url.lastPathComponent) 到复制队列")
                        droppedFiles.append(url)
                    }
                    dispatchGroup.leave()
                }
            }

            dispatchGroup.notify(queue: self.bg) {
                self.emitCopyFiles(droppedFiles)
            }
        }

        return true
    }

    func onSorting(_ notification: Notification) {
        os_log("\(label)onSorting")
        isSorting = true
        if let mode = notification.userInfo?["mode"] as? String {
            sortMode = SortMode(rawValue: mode) ?? .none
        }
    }

    func onSortDone(_ notification: Notification) {
        os_log("\(label)onSortDone")
        isSorting = false
    }
}

// MARK: Event Name 

extension Notification.Name {
    static let CopyFiles = Notification.Name("CopyFiles")
}

// MARK: Event Emit

extension AudioDB {
    func emitCopyFiles(_ urls: [URL]) {
        self.main.async {
            NotificationCenter.default.post(name: .CopyFiles, object: self, userInfo: ["urls": urls])
        }
    }
}

#Preview("APP") {
    AppPreview()
        .frame(height: 800)
}

#Preview("Layout") {
    LayoutView()
}
