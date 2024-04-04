import Foundation
import OSLog
import SwiftData
import SwiftUI

/**
 DB 负责
 - 对接文件系统
 - 提供 Audio
 - 操作 Audio
 */
actor DB: ModelActor {
    let modelContainer: ModelContainer
    let modelExecutor: any ModelExecutor

    var fileManager = FileManager.default
    var cloudHandler = CloudHandler()
    var bg = AppConfig.bgQueue
    var audiosDir: URL = AppConfig.audiosDir
    var handler = CloudHandler()
    var context: ModelContext

    init(_ container: ModelContainer) {
        os_log("\(Logger.isMain)🚩 初始化 DB")

        modelContainer = container
        context = ModelContext(container)
        context.autosaveEnabled = false
        modelExecutor = DefaultSerialModelExecutor(
            modelContext: context
        )

        Task {
            await getAudios()
        }
    }
}

// MARK: 增加

extension DB {
    /// 往数据库添加文件
    func add(
        _ urls: [URL],
        completionAll: @escaping () -> Void,
        completionOne: @escaping (_ sourceUrl: URL) -> Void,
        onStart: @escaping (_ audio: Audio) -> Void
    ) {
        for url in urls {
            onStart(Audio(url))
            SmartFile(url: url).copyTo(
                destnation: audiosDir.appendingPathComponent(url.lastPathComponent))
            completionOne(url)
        }

        completionAll()
    }
}

// MARK: 删除

extension DB {
    func delete(_ audio: Audio) {
        let url = audio.url
        let trashUrl = AppConfig.trashDir.appendingPathComponent(url.lastPathComponent)

        Task {
            try await cloudHandler.moveFile(at: audio.url, to: trashUrl)
        }
    }

    /// 清空数据库
    func destroy() {
        clearFolderContents(atPath: audiosDir.path)
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
}

// MARK: 查询

extension DB {
    /// 查询数据，当查到或有更新时会调用回调函数
    func getAudios() {
        os_log("\(Logger.isMain)🍋 DB::getAudios")
        let query = ItemQuery(queue: OperationQueue(), url: audiosDir)
        Task {
            for try await items in query.searchMetadataItems() {
                os_log("\(Logger.isMain)🍋 DB::getAudios \(items.count)")
                self.upsert(items.filter { $0.url != nil })
            }
        }
    }

    func find(_ url: URL) -> PlayItem? {
        let predicate = #Predicate<PlayItem> {
            $0.url == url
        }
        var descriptor = FetchDescriptor<PlayItem>(predicate: predicate)
        descriptor.fetchLimit = 1
        do {
            let result = try context.fetch(descriptor)
            return result.first
        } catch let e {
            print(e)
        }

        return nil
    }

    static func find(_ context: ModelContext, _ url: URL) -> PlayItem? {
        let predicate = #Predicate<PlayItem> {
            $0.url == url
        }
        var descriptor = FetchDescriptor<PlayItem>(predicate: predicate)
        descriptor.fetchLimit = 1
        do {
            let result = try context.fetch(descriptor)
            return result.first
        } catch let e {
            print(e)
        }

        return nil
    }
}

// MARK: 修改

extension DB {
    func download(_ url: URL) {
        Task {
            try? await CloudHandler().download(url: url)
        }
    }

    nonisolated func upsert(_ items: [MetadataItemWrapper]) {
        Task.detached {
            let context = ModelContext(self.modelContainer)
            context.autosaveEnabled = false
            for item in items {
                if let current = Self.find(context, item.url!) {
                    //os_log("\(Logger.isMain)🍋 DB::更新 \(current.title)")
                    current.isDownloading = item.isDownloading
                    current.downloadingPercent = item.downloadProgress
                } else {
                    os_log("\(Logger.isMain)🍋 DB::插入")
                    let playItem = PlayItem(item.url!)
                    playItem.isDownloading = item.isDownloading
                    playItem.downloadingPercent = item.downloadProgress
                    context.insert(playItem)
                }
            }

            os_log("\(Logger.isMain)🍋 DB::保存")
            try? context.save()
        }
    }
}

#Preview {
    RootView {
        ContentView()
    }
}
