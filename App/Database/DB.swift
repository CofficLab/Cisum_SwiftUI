import Foundation
import OSLog
import SwiftUI

class DB {
    var fileManager = FileManager.default
    var bg = AppConfig.bgQueue
    var timer: Timer?
    var cloudDisk: URL
    var queryUpdateWorkItem: DispatchWorkItem?
    var onDownloadingWorkItem: DispatchWorkItem?
    var onUpdate: ([AudioModel]) -> Void = { _ in os_log("🍋 DB::onUpdate") }

    init(cloudDisk: URL) {
        os_log("\(Logger.isMain)🚩 初始化 DB")

        self.cloudDisk = cloudDisk.appendingPathComponent(AppConfig.audiosDirName)
        self.createAudiosFolder()
        self.onAudiosFolderUpdate()
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
}

// MARK: 监听变化

extension DB {
    var n: NotificationCenter { NotificationCenter.default }

    func onAudiosFolderUpdate() {
        let query = NSMetadataQuery()
        query.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
        query.predicate = NSPredicate(format: "%K BEGINSWITH %@", NSMetadataItemPathKey, cloudDisk.path + "/")

        n.addObserver(forName: NSNotification.Name.NSMetadataQueryDidUpdate, object: query, queue: nil) { _ in
            self.bg.async {
                self.queryUpdateWorkItem?.cancel()
                self.queryUpdateWorkItem = DispatchWorkItem {
                    //os_log("\(Logger.isMain)🏠 DB::QueryDidUpdate")
                    self.onUpdate(self.getAudiosFromQuery(query))
                }
                DispatchQueue.global().asyncAfter(deadline: .now() + 1, execute: self.queryUpdateWorkItem!)
            }
        }

        n.addObserver(forName: NSNotification.Name.NSMetadataQueryDidFinishGathering, object: query, queue: nil) { _ in
            self.bg.async {
                os_log("\(Logger.isMain)🏠 DB::DidFinishGathering")
                self.onUpdate(self.getAudiosFromQuery(query))
            }
        }

        // query.enableUpdates()
        query.start()
    }
    
    private func getAudiosFromQuery(_ query: NSMetadataQuery) -> [AudioModel] {
        var audios: [AudioModel] = []
        if let items = query.results as? [NSMetadataItem] {
            //os_log("\(Logger.isMain)🍋 DB::变动的items个数 \(items.count)")

            for item in items {
                let percentDownloaded =
                    item.value(forAttribute: NSMetadataUbiquitousItemPercentDownloadedKey) as? Double
                let isDownloading =
                    item.value(forAttribute: NSMetadataUbiquitousItemIsDownloadingKey) as? String
                let url = item.value(forAttribute: NSMetadataItemURLKey) as? URL

                if let u = url {
//                    os_log("\(Logger.isMain)🍋 DB::变动 \(u.lastPathComponent)")
                    let audio = AudioModel(u)
                    if let p = percentDownloaded, p < 100 && p >  0 {
                        //os_log("\(Logger.isMain)🍋 DB::变动 \(p) 🐛 \(u.lastPathComponent) 🐛 \(p)")
                        audio.downloadingPercent = p
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
