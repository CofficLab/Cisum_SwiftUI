import Foundation
import OSLog
import SwiftUI

class DBManager: ObservableObject {
    @EnvironmentObject var appManager: AppManager

    @Published private(set) var files: [URL] = []
    @Published var audios: [AudioModel] = []
    @Published var isReady: Bool = false
    @Published var isCloudStorage: Bool = false
    
    var isEmpty: Bool {
        self.isReady && self.audios.isEmpty
    }

    static var preview: DBManager = DBManager(rootDir: iCloudHelper.getiCloudDocumentsUrl())

    var dbModel: DBModel
    var queue = AppConfig.bgQueue

    init(rootDir: URL) {
        os_log("🚩 DBManager::Init")
        dbModel = DBModel(cloudDisk: rootDir)
        isCloudStorage = iCloudHelper.isCloudPath(url: rootDir)

        refresh()
    }

    func delete(urls: Set<URL>) async {
        await AudioModel.delete(urls: urls)
        self.refresh()
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
                os_log("🍋 DBManager::Refreshed")
            }
        }
    }
}

#Preview {
    RootView {
        ContentView(play: false)
    }
}
