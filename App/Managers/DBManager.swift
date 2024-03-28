import Foundation
import OSLog
import SwiftUI

class DBManager: ObservableObject {
    @EnvironmentObject var appManager: AppManager

    @Published private(set) var files: [URL] = []
    @Published var audios: [AudioModel] = []
    @Published var isReady: Bool = false
    @Published var isCloudStorage: Bool = false
    @Published var updatedAt: Date = .now

    var isEmpty: Bool {
        isReady && audios.isEmpty
    }

    static var preview: DBManager = .init(rootDir: iCloudHelper.getiCloudDocumentsUrl())

    var dbModel: DBModel
    var queue = AppConfig.bgQueue

    init(rootDir: URL) {
        os_log("\(Logger.isMain)🚩 DBManager::Init")
        self.dbModel = DBModel(cloudDisk: rootDir)
        dbModel.onUpdate = refresh
        self.isCloudStorage = iCloudHelper.isCloudPath(url: rootDir)

        refresh()
    }

    func delete(urls: Set<URL>) async {
        await AudioModel.delete(urls: urls)
        refresh()
    }

    func destroy() {
        dbModel.destroy()
        refresh()
    }

    func refresh() {
        queue.async {
            let files = self.dbModel.getFiles()
            let audios = self.dbModel.getAudioModels()

            AppConfig.mainQueue.async {
                self.files = files
                self.audios = audios
                self.isReady = true
                self.updatedAt = .now
                os_log("\(Logger.isMain)🍋 DBManager::Refreshed")
            }
        }
    }
}

#Preview {
    RootView {
        ContentView()
    }
}
