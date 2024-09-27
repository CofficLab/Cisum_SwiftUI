import Foundation
import OSLog
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct AudioDB: View {
    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var data: DataProvider
    @EnvironmentObject var db: DB

    @State var treeView = false
    @State var isSorting = false
    @State var sortMode: String?

    @Query(Audio.descriptorAll, animation: .default) var audios: [Audio]

    static var label = "🐘 DBLayout::"

    var main = Config.mainQueue
    var bg = Config.bgQueue
    var dropping: Bool { app.isDropping }
    var disk: any Disk { data.disk }
    var label: String { "\(Logger.isMain)\(Self.label) " }

    init(verbose: Bool = false) {
        if verbose {
            os_log("\(Logger.isMain)\(Self.label)初始化")
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            if isSorting {
                if let mode = sortMode {
                    if mode == "random" {
                        Text("正在随机排序...")
                    } else if mode == "order" {
                        Text("正在顺序排序...")
                    } else {
                        Text("正在排序...")
                    }
                } else {
                    Text("正在排序...")
                }
            } else {
                AudioVStack(reason: "AudioDB")
                    .frame(maxHeight: .infinity)
            }

            TaskView()
                .shadow(radius: 10)
        }
        .fileImporter(
            isPresented: $app.isImporting,
            allowedContentTypes: [.audio],
            allowsMultipleSelection: true,
            onCompletion: { result in
                switch result {
                case let .success(urls):
                    copy(urls)
                case let .failure(error):
                    os_log(.error, "导入文件失败Error: \(error.localizedDescription)")
                }
            }
        )
        .onReceive(NotificationCenter.default.publisher(for: .DBSorting), perform: onSorting)
        .onReceive(NotificationCenter.default.publisher(for: .DBSortDone), perform: onSortDone)
        .onDrop(of: [UTType.fileURL], isTargeted: $app.isDropping, perform: onDrop)
    }
}

// MARK: 操作

extension AudioDB {
    func copy(_ files: [URL]) {
        data.copy(files)
    }

    func setFlashMessage(_ m: String) {
        main.async {
            app.setFlashMessage(m)
            self.cleanStateMessage()
        }
    }

    func setStateMessage(_ m: String) {
        main.async {
            app.stateMessage = m
        }
    }

    func cleanStateMessage() {
        main.async {
            app.cleanStateMessage()
        }
    }
}

// MARK: Event Handle

extension AudioDB {
    func onDrop(_ providers: [NSItemProvider]) -> Bool {
        let dispatchGroup = DispatchGroup()
            var dropedFiles: [URL] = []
            for provider in providers {
                dispatchGroup.enter()
                // 这是异步操作
                _ = provider.loadObject(ofClass: URL.self) { object, _ in
                    if let url = object {
                        os_log("\(Logger.isMain)🖥️ DBView::添加 \(url.lastPathComponent) 到复制队列")
                        dropedFiles.append(url)
                    }

                    dispatchGroup.leave()
                }
            }

            dispatchGroup.notify(queue: .main) {
                copy(dropedFiles)
            }

        return true
    }

    func onSorting(_ notification: Notification) {
        os_log("\(label)onSorting")
        isSorting = true
        if let mode = notification.userInfo?["mode"] as? String {
            sortMode = mode
        }
    }

    func onSortDone(_ notification: Notification) {
        os_log("\(label)onSortDone")
        isSorting = false
    }
}

#Preview("APP") {
    AppPreview()
        .frame(height: 800)
}

#Preview("Layout") {
    LayoutView()
}
