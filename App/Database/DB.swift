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
class DB {
    var fileManager = FileManager.default
    var cloudHandler = CloudHandler()
    var bg = AppConfig.bgQueue
    var audiosDir: URL = AppConfig.audiosDir
    var handler = CloudHandler()
    var context: ModelContext

    init(context: ModelContext) {
        os_log("\(Logger.isMain)🚩 初始化 DB")

        self.context = context
        Task {
            await self.getAudios()
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
        onStart: @escaping (_ audio: Audio) -> Void
    ) {
        bg.async {
            for url in urls {
                onStart(Audio(url))
                SmartFile(url: url).copyTo(
                    destnation: self.audiosDir.appendingPathComponent(url.lastPathComponent))
                completionOne(url)
            }

            completionAll()
        }
    }

    // MARK: 删除

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

    // MARK: 查询

    /// 查询数据，当查到或有更新时会调用回调函数
    @MainActor
    func getAudios() {
        Task {
            // 创建一个后台队列
            let backgroundQueue = OperationQueue()
            let query = ItemQuery(queue: backgroundQueue, url: self.audiosDir)
            for await items in query.searchMetadataItems() {
                AppConfig.bgQueue.async {
                    items.filter { $0.url != nil }.forEach { item in
                        do {
                            let url = item.url!
                            let predicate = #Predicate<PlayItem> {
                                $0.url == url
                            }
                            let descriptor = FetchDescriptor(predicate: predicate)
                            let dbItems = try self.context.fetch(descriptor)

                            if let f = dbItems.first {
                                os_log("\(Logger.isMain)🍋 DB::getAudios 更新 \(f.title)")
                            } else {
                                let playItem = PlayItem(url)
                                self.context.insert(playItem)
                                //os_log("\(Logger.isMain)🍋 DB::getAudios 入库 \(playItem.title)")
                            }
                        } catch let e {
                            print(e)
                        }
                    }
                }
            }
        }
    }

    // MARK: 修改

    func download(_ url: URL) {
        Task {
            try? await CloudHandler().download(url: url)
        }
    }
}

#Preview {
    RootView {
        ContentView()
    }
}
