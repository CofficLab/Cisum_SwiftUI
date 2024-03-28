import Foundation
import OSLog
import SwiftUI

class DBModel {
    var fileManager = FileManager.default
    var queue = DispatchQueue.global()
    var timer: Timer?
    var cloudDisk: URL
    var onUpdate: () -> Void = { os_log("🍋 DBModel::onUpdate") }
    var onDownloading: (_ url: URL, _ percent: Double) -> Void = {url,percent in
        os_log("🍋 DBModel::onDownloading -> \(url.lastPathComponent) -> \(percent)")
    }

    init(cloudDisk: URL, 
         onUpdate: (() -> Void)? = nil,
         onDownloading: ((_ url: URL, _ percent: Double) -> Void)? = nil
    ) {
        os_log("\(Logger.isMain)🚩 初始化 DBModel")

        self.onUpdate = onUpdate ?? self.onUpdate
        self.onDownloading = onDownloading ?? self.onDownloading
        self.cloudDisk = cloudDisk.appendingPathComponent(AppConfig.audiosDirName)

        do {
            try fileManager.createDirectory(at: self.cloudDisk, withIntermediateDirectories: true)
            os_log("\(Logger.isMain)🍋 DBModel::创建 Audios 目录成功")
        } catch {
            os_log("\(Logger.isMain)创建 Audios 目录失败\n\(error.localizedDescription)")
        }

        startWatch()
    }
}

// MARK: 增删改查

extension DBModel {
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

    func getAudioModels() -> [AudioModel] {
        getFiles().map {
            AudioModel($0)
        }
    }

    /// 获取目录里的文件列表
    func getFiles() -> [URL] {
        var fileNames: [URL] = []
        var downloaded: [URL] = []
        var downloading: [URL] = []

        do {
            try fileNames = fileManager.contentsOfDirectory(
                at: cloudDisk, includingPropertiesForKeys: nil
            )
        } catch {
            os_log("\(Logger.isMain)读取目录发生错误，目录是\n\(self.cloudDisk)\n\(error)")
        }

        // 排序
        fileNames = fileNames.sorted {
            $0.lastPathComponent.localizedCaseInsensitiveCompare($1.lastPathComponent)
                == .orderedAscending
        }

        //  只需要音频文件
        fileNames = fileNames.filter {
            FileHelper.isAudioFile(url: $0) || $0.pathExtension == "downloading"
        }

        // 分类
        downloaded = fileNames.filter { $0.pathExtension != "downloading" }
        downloading = fileNames.filter { $0.pathExtension == "downloading" }

        os_log(
            "\(Logger.isMain)🏠 DBModel::total \(fileNames.count) downloaded \(downloaded.count) downloading \(downloading.count)"
        )
        return downloaded + downloading
    }
}

// MARK: 监听变化

extension DBModel {
    var n: NotificationCenter { NotificationCenter.default }

    func startWatch() {
        onAudiosFolderUpdate()
    }

    func onAudiosFolderUpdate() {
        let query = NSMetadataQuery()
        query.searchScopes = [
            NSMetadataQueryUbiquitousDocumentsScope
        ]
        query.predicate = NSPredicate(format: "%K BEGINSWITH %@", NSMetadataItemPathKey, cloudDisk.path)

        n.addObserver(forName: NSNotification.Name.NSMetadataQueryDidUpdate, object: query, queue: nil) { _ in
            if let items = query.results as? [NSMetadataItem] {
                os_log("🍋 DBModel::变动的items个数 \(items.count)")
                self.onUpdate()

                for item in items {
                    let downloadingStatus = item.value(forAttribute: NSMetadataUbiquitousItemDownloadingStatusKey) as? String
                    let percentDownloaded = item.value(forAttribute: NSMetadataUbiquitousItemPercentDownloadedKey) as? Double
                    let isDownloading = item.value(forAttribute: NSMetadataUbiquitousItemIsDownloadingKey) as? String
                    let url = item.value(forAttribute: NSMetadataItemURLKey) as? URL
                    
                    
                    
                    if isDownloading != nil {
                        print("isDownloading -> \(url!.lastPathComponent)")
                    }
                    
                    if url != nil, percentDownloaded != nil, percentDownloaded! <= 100.0 {
                        print("Percent downloaded -> \(String(describing: percentDownloaded))")
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
