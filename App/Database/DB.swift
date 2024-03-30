import Foundation
import OSLog
import SwiftUI

class DB {
    var fileManager = FileManager.default
    var bg = AppConfig.bgQueue
    var timer: Timer?
    var cloudDisk: URL
    var handler = CloudDocumentsHandler()
    var queryUpdateWorkItem: DispatchWorkItem?
    var onDownloadingWorkItem: DispatchWorkItem?
    var onUpdate: ([AudioModel]) -> Void = { _ in os_log("🍋 DB::onUpdate") }
    var onGet: ([AudioModel]) -> Void = { _ in os_log("🍋 DB::onGet") }

    init(cloudDisk: URL) {
        os_log("\(Logger.isMain)🚩 初始化 DB")

        self.cloudDisk = cloudDisk.appendingPathComponent(AppConfig.audiosDirName)
        createAudiosFolder()
        onAudiosFolderUpdate()

        Task {
            await self.getAudios({
                self.onGet($0)
            })
        }

        Task {
            os_log("🚩 DB::监听数据库文件夹")
            await self.handler.startMonitoringFile(at: cloudDisk, onDidChange: {
                Task {
                    await self.getAudios({
                        self.onUpdate($0)
                    })
                }
            })
        }
    }

    func createAudiosFolder() {
        if fileManager.fileExists(atPath: cloudDisk.path) {
            return
        }

        do {
            try fileManager.createDirectory(at: cloudDisk, withIntermediateDirectories: true)
            os_log("\(Logger.isMain)🍋 DB::创建 Audios 目录成功")
        } catch {
            os_log("\(Logger.isMain)创建 Audios 目录失败\n\(error.localizedDescription)")
        }
    }
}

// MARK: 增删改查

extension DB {
    // MARK: 增加

    /// 往数据库添加文件
    func add(
        _ urls: [URL],
        completionAll: @escaping () -> Void,
        completionOne: @escaping (_ sourceUrl: URL) -> Void,
        onStart: @escaping (_ url: URL) -> Void
    ) {
        bg.async {
            for url in urls {
                onStart(url)
                SmartFile(url: url).copyTo(
                    destnation: self.cloudDisk.appendingPathComponent(url.lastPathComponent))
                completionOne(url)
            }

            completionAll()
        }
    }

    // MARK: 删除

    /// 清空数据库
    func destroy() {
        clearFolderContents(atPath: cloudDisk.path)
    }

    func clearFolderContents(atPath path: String) {
        let fileManager = FileManager.default
        do {
            let contents = try fileManager.contentsOfDirectory(atPath: path)
            for item in contents {
                let itemPath = URL(fileURLWithPath: path).appendingPathComponent(item).path
                try fileManager.removeItem(atPath: itemPath)
            }
        } catch {
            print("Error: \(error)")
        }
    }

    // MARK: 查询

    @MainActor
    func getAudios(_ callback: @escaping ([AudioModel]) -> Void) {
        var audios: [AudioModel] = []
        Task {
            let query = ItemQuery()
            for await items in query.searchMetadataItems() {
                items.forEach { item in
                    if let u = item.url {
                        var audio = AudioModel(u)
                        audio.downloadingPercent = item.downloadProgress
                        audio.isDownloading = item.isDownloading
                        audios.append(audio)
                    }
//                    print(item.fileName ?? "",
//                                  ":",
//                                  $0.isDirectory,
//                                  $0.url ?? "url"
//                                  $0.directoryURL ?? "dirURL",
//                                  $0.contentType ?? "type",
//                                  "placeHolder:", $0.isPlaceholder,
//                                  "isDownloading:", $0.isDownloading,
//                                  "progress:", item.downloadProgress
//                                  "upLoaded:", $0.uploaded
//                    )
                }
                
                callback(audios)
            }
        }
    }
}

// MARK: 监听变化

extension DB {
    var n: NotificationCenter { NotificationCenter.default }

    func onAudiosFolderUpdate() {
        let query = NSMetadataQuery()
        query.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
        query.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "%K BEGINSWITH %@", NSMetadataItemPathKey, cloudDisk.path + "/"),
//            NSPredicate(format: "%K ENDSWITH %@", NSMetadataItemFSNameKey, ".mp3")
        ])

        n.addObserver(forName: NSNotification.Name.NSMetadataQueryDidUpdate, object: query, queue: nil) { _ in
            self.bg.async {
                self.queryUpdateWorkItem?.cancel()
                self.queryUpdateWorkItem = DispatchWorkItem {
                    // os_log("\(Logger.isMain)🏠 DB::QueryDidUpdate")
                    self.onUpdate(self.getAudiosFromQuery(query))
                }
                DispatchQueue.global().asyncAfter(deadline: .now() + 0.12, execute: self.queryUpdateWorkItem!)
            }
        }

        n.addObserver(forName: NSNotification.Name.NSMetadataQueryDidFinishGathering, object: query, queue: nil) { _ in
            self.bg.async {
                os_log("\(Logger.isMain)🏠 DB::DidFinishGathering")
                self.onGet(self.getAudiosFromQuery(query))
            }
        }

        // query.enableUpdates()
        query.start()
    }

    private func getAudiosFromQuery(_ query: NSMetadataQuery) -> [AudioModel] {
        var audios: [AudioModel] = []
        if let items = query.results as? [NSMetadataItem] {
            // os_log("\(Logger.isMain)🍋 DB::变动的items个数 \(items.count)")

            for item in items {
                let percentDownloaded =
                    item.value(forAttribute: NSMetadataUbiquitousItemPercentDownloadedKey) as? Double
                let isDownloading =
                    item.value(forAttribute: NSMetadataUbiquitousItemIsDownloadingKey) as? Bool
                let url = item.value(forAttribute: NSMetadataItemURLKey) as? URL

                if let u = url {
                    // os_log("\(Logger.isMain)🍋 DB::变动 \(u.lastPathComponent)")
                    let audio = AudioModel(u)

                    if iCloudHelper.isDownloaded(url: u) {
                        audio.downloadingPercent = 100
                        audio.isDownloading = false
                    }

                    if isDownloading == true, let p = percentDownloaded {
                        os_log("\(Logger.isMain)🍋 DB::变动 🐛 \(u.lastPathComponent) 🐛 isDownloading ⬇️⬇️⬇️ \(p)")
                        audio.isDownloading = true
                    }

                    audios.append(audio)
                }
            }
        }

        return audios
    }
}

#Preview {
    RootView {
        ContentView()
    }
}
