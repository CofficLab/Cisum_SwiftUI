import Foundation
import OSLog
import SwiftUI

class DB {
    var fileManager = FileManager.default
    var bg = AppConfig.bgQueue
    var audiosDir: URL = AppConfig.audiosDir
    var handler = CloudDocumentsHandler()
    var onGet: ([AudioModel]) -> Void = { _  in os_log("🍋 DB::onGet") }

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
        onStart: @escaping (_ url: URL) -> Void
    ) {
        bg.async {
            for url in urls {
                onStart(url)
                SmartFile(url: url).copyTo(
                    destnation: self.audiosDir.appendingPathComponent(url.lastPathComponent))
                completionOne(url)
            }

            completionAll()
        }
    }

    // MARK: 删除

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
    func getAudios(_ callback: @escaping ([AudioModel]) -> Void) {
        Task {
            let query = ItemQuery(url: self.audiosDir)
            for await items in query.searchMetadataItems() {
                let audios = items.filter({ $0.url != nil}).map { item in
                    let audio = AudioModel(item.url!)
                    audio.downloadingPercent = item.downloadProgress
                    audio.isDownloading = item.isDownloading
                    return audio
                }
                
                os_log("🍋 DB::getAudios with \(audios.count)")
                callback(audios)
            }
        }
    }
}

#Preview {
    RootView {
        ContentView()
    }
}
