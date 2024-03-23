import Foundation
import OSLog
import SwiftUI

class DatabaseManager: ObservableObject {
    @EnvironmentObject var appManager: AppManager

    @Published private(set) var files: [URL] = []
    @Published var audios: [AudioModel] = []
    @Published var isReady: Bool = false
    @Published var isCloudStorage: Bool = false
    
    var isEmpty: Bool {
        self.isReady && self.audios.isEmpty
    }

    static var preview: DatabaseManager = DatabaseManager(rootDir: iCloudHelper.getiCloudDocumentsUrl())

    private var databaseModel: DatabaseModel

    init(rootDir: URL) {
        AppConfig.logger.databaseManager.info("初始化 DatabaseManager")
        databaseModel = DatabaseModel(rootDir: rootDir)
        isCloudStorage = iCloudHelper.isCloudPath(url: rootDir)

        refresh()
    }

    func delete(urls: Set<URL>, callback: @escaping () -> Void) {
        databaseModel.delete(urls: urls, callback: {
            self.refresh()
            callback()
        })
    }

    func add(_ urls: [URL], completionAll: @escaping () -> Void = {}, completionOne: @escaping (_ url:URL) -> Void = {_ in}) {
        databaseModel.add(
            urls,
            completionAll: {
                self.refresh()
                AppConfig.mainQueue.async {
                    completionAll()
                }
            },
            completionOne: { url in
                AppConfig.mainQueue.async {
                    completionOne(url)
                }
            }
        )
    }

    func downloadOne(_ url: URL) -> Bool {
        databaseModel.downloadOne(url)
    }

    private func refresh() {
        AppConfig.logger.databaseManager.debug("DatabaseManager 刷新数据")
        AppConfig.bgQueue.async {
            let files = self.databaseModel.getFiles()
            let audios = files.map { AudioModel($0) }
            
            AppConfig.mainQueue.async {
                self.files = files
                self.audios = audios
                self.isReady = true
                AppConfig.logger.databaseManager.debug("DataseManager 刷新完成")
            }
        }
    }
}
