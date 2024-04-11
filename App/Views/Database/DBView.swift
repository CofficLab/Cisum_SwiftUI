import Foundation
import OSLog
import SwiftUI
import UniformTypeIdentifiers

struct DBView: View {
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var appManager: AppManager

    var main = AppConfig.mainQueue
    var bg = AppConfig.bgQueue
    var db: DB { audioManager.db }
    var dbFolder: DBFolder = .init()
    var dropping: Bool { appManager.isDropping }

    var body: some View {
        DBList()
            .fileImporter(
                isPresented: $appManager.isImporting,
                allowedContentTypes: [.audio],
                allowsMultipleSelection: true,
                onCompletion: { result in
                    switch result {
                    case let .success(urls):
                        copy(urls)
                    case let .failure(error):
                        print("导入文件失败Error: \(error)")
                    }
                }
            )
            .onDrop(of: [UTType.fileURL], isTargeted: $appManager.isDropping) { providers -> Bool in
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
    }

    init() {
        //os_log("\(Logger.isMain)🚩 DBView::Init")
    }
}

// MARK: 操作

extension DBView {
    func copy(_ files: [URL]) {
        Task {
            await db.add(files)
        }
    }

    func setFlashMessage(_ m: String) {
        main.async {
            appManager.setFlashMessage(m)
            self.cleanStateMessage()
        }
    }

    func setStateMessage(_ m: String) {
        main.async {
            appManager.stateMessage = m
        }
    }

    func cleanStateMessage() {
        main.async {
            appManager.cleanStateMessage()
        }
    }
}

#Preview("APP") {
    RootView {
        ContentView()
    }.modelContainer(AppConfig.getContainer())
}

#Preview {
    RootView {
        DBView().frame(width: 300)
    }.modelContainer(AppConfig.getContainer())
}

#Preview {
    RootView {
        DBView().frame(width: 350)
    }.modelContainer(AppConfig.getContainer())
}

#Preview {
    RootView {
        DBView().frame(width: 400)
    }.modelContainer(AppConfig.getContainer())
}

#Preview {
    RootView {
        DBView().frame(width: 500)
    }.modelContainer(AppConfig.getContainer())
}

#Preview {
    RootView {
        DBView().frame(width: 600)
    }.modelContainer(AppConfig.getContainer())
}
