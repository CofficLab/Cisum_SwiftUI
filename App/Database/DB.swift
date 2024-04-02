import Foundation
import OSLog
import SwiftUI

/**
 DB 负责
 - 对接文件系统
 - 提供 Audio
 - 操作 Audio
 */
class DB {
    var fileManager = FileManager.default
    var bg = AppConfig.bgQueue
    var audiosDir: URL = AppConfig.audiosDir
    var handler = CloudHandler()
    var onGet: ([Audio]) -> Void = { _  in os_log("🍋 DB::onGet") }

    init() {
        os_log("\(Logger.isMain)🚩 初始化 DB")

        Task {
            await self.getAudios({
                self.onGet($0)
            })
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
                onStart(Audio(url, db: self))
                SmartFile(url: url).copyTo(
                    destnation: self.audiosDir.appendingPathComponent(url.lastPathComponent))
                completionOne(url)
            }

            completionAll()
        }
    }

    // MARK: 删除
    
    func delete(_ url: URL) {
        do {
            if fileManager.fileExists(atPath: url.path) {
                try fileManager.removeItem(at: url)
                SmartFile(url: url).delete()
            } else {
                os_log("\(Logger.isMain)删除时发现文件不存在，忽略 -> \(url.lastPathComponent)")
            }
        } catch {
            os_log(.error, "删除文件失败\n\(error)")
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
    func getAudios(_ callback: @escaping ([Audio]) -> Void) {
        Task {
            let query = ItemQuery(url: self.audiosDir)
            for await items in query.searchMetadataItems() {
                let audios = items.filter({ $0.url != nil}).map { item in
                    let audio = Audio(item.url!, db: self)
                    audio.downloadingPercent = item.downloadProgress
                    audio.isDownloading = item.isDownloading
                    return audio
                }
                
                os_log("🍋 DB::getAudios with \(audios.count)")
                callback(audios)
            }
        }
    }
    
    // MARK: 修改
    func download(_ url: URL) {
        Task {
            try? await CloudHandler().download(url:url)
        }
    }
}

#Preview {
    RootView {
        ContentView()
    }
}
