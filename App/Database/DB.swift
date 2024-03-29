import Foundation
import OSLog
import SwiftUI

class DB {
    var fileManager = FileManager.default
    var queue = AppConfig.bgQueue
    var timer: Timer?
    var cloudDisk: URL
    var onUpdate: () -> Void = { os_log("🍋 DB::onUpdate") }
    var onDownloading: (_ url: URL, _ percent: Double) -> Void = { url, percent in
        os_log("🍋 DB::onDownloading -> \(url.lastPathComponent) -> \(percent)")
    }

    init(
        cloudDisk: URL,
        onUpdate: (() -> Void)? = nil,
        onDownloading: ((_ url: URL, _ percent: Double) -> Void)? = nil
    ) {
        os_log("\(Logger.isMain)🚩 初始化 DB")
        
        self.cloudDisk = cloudDisk.appendingPathComponent(AppConfig.audiosDirName)
        self.createAudiosFolder()
        Task {
            self.onUpdate = onUpdate ?? self.onUpdate
            self.onDownloading = onDownloading ?? self.onDownloading
            self.onAudiosFolderUpdate()
        }
    }
    
    func createAudiosFolder() {
        if fileManager.fileExists(atPath: self.cloudDisk.path) {
            return
        }
        
        do {
            try fileManager.createDirectory(at: self.cloudDisk, withIntermediateDirectories: true)
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
        queue.async {
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

    func getAudioModels(_ reason: String, onUpdate: @escaping ([AudioModel]) -> Void) {
        getFiles(reason, onUpdate: {
            onUpdate($0.map { AudioModel($0) })
        })
    }

    /// 获取目录里的文件列表
    func getFiles(_ reason: String, onUpdate: @escaping (Set<URL>) -> Void) {
        os_log("\(Logger.isMain)🏠 DB::getFiles 🐛 \(reason)")
        
        var files: Set<URL> = []
        let query = NSMetadataQuery()
        query.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
        // 以根目录开头的文件，即根目录下的所有文件
        query.predicate = NSPredicate(
            format: "%K BEGINSWITH %@",
            NSMetadataItemPathKey,
            cloudDisk.path)

        n.addObserver(forName: NSNotification.Name.NSMetadataQueryDidUpdate, object: query, queue: nil) { _ in
            if let items = query.results as? [NSMetadataItem] {
                os_log("🍋 DB::变动的items个数 \(items.count)")

                for item in items {
                    let percentDownloaded =
                        item.value(forAttribute: NSMetadataUbiquitousItemPercentDownloadedKey) as? Double
                    let isDownloading =
                        item.value(forAttribute: NSMetadataUbiquitousItemIsDownloadingKey) as? String
                    let url = item.value(forAttribute: NSMetadataItemURLKey) as? URL

                    if url != nil, percentDownloaded != nil, percentDownloaded! <= 100.0 {
                        self.onDownloading(url!, percentDownloaded!)
                    }
                    
                    if let u = url {
                        files.insert(u)
                    }
                }
                
                onUpdate(files)
            }
        }
        
        n.addObserver(forName: NSNotification.Name.NSMetadataQueryDidFinishGathering, object: query, queue: nil) { _ in
            if let items = query.results as? [NSMetadataItem] {
                os_log("🍋 DB::FinishGathering 变动的items个数 \(items.count)")

                for item in items {
                    let url = item.value(forAttribute: NSMetadataItemURLKey) as? URL
                    
                    if let u = url {
                        files.insert(u)
                    }
                }
                
                onUpdate(files)
            }
        }

        // query.enableUpdates()
        query.start()
    }
}

// MARK: 监听变化

extension DB {
    var n: NotificationCenter { NotificationCenter.default }

    func onAudiosFolderUpdate() {
        let query = NSMetadataQuery()
        query.searchScopes = [
            NSMetadataQueryUbiquitousDocumentsScope
        ]
        query.predicate = NSPredicate(format: "%K BEGINSWITH %@", NSMetadataItemPathKey, cloudDisk.path)

        n.addObserver(forName: NSNotification.Name.NSMetadataQueryDidUpdate, object: query, queue: nil) { _ in
            if let items = query.results as? [NSMetadataItem] {
                os_log("🍋 DB::变动的items个数 \(items.count)")
                self.onUpdate()

                for item in items {
                    let downloadingStatus =
                        item.value(forAttribute: NSMetadataUbiquitousItemDownloadingStatusKey) as? String
                    let percentDownloaded =
                        item.value(forAttribute: NSMetadataUbiquitousItemPercentDownloadedKey) as? Double
                    let isDownloading =
                        item.value(forAttribute: NSMetadataUbiquitousItemIsDownloadingKey) as? String
                    let url = item.value(forAttribute: NSMetadataItemURLKey) as? URL

                    if isDownloading != nil {
                        print("isDownloading -> \(url!.lastPathComponent)")
                    }

                    if url != nil, percentDownloaded != nil, percentDownloaded! <= 100.0 {
                        self.onDownloading(url!, percentDownloaded!)
                    }
                }
            }
        }

        // query.enableUpdates()
        query.start()
    }
}

#Preview {
    RootView {
        ContentView()
    }
}
