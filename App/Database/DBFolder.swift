import Foundation
import OSLog

class DBFolder: ObservableObject {
    var fileManager = FileManager.default
    var cloudHandler = CloudHandler()
    var audiosDir: URL = AppConfig.audiosDir
    var bg = AppConfig.bgQueue
    
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
    
    @MainActor func trash(_ audio: Audio) {
        let url = audio.url
        let ext = audio.ext
        let fileName = audio.title
        let trashDir = AppConfig.trashDir
        var trashUrl = trashDir.appendingPathComponent(url.lastPathComponent)
        var times = 1
        
        // 回收站已经存在同名文件
        while fileManager.fileExists(atPath: trashUrl.path) {
            trashUrl = trashUrl.deletingLastPathComponent()
                .appendingPathComponent("\(fileName)-\(times)")
                .appendingPathExtension(ext)
            times += 1
        }
        
        Task {
            // 文件不存在
            if !fileManager.fileExists(atPath: audio.url.path) {
                return
            }
            
            // 移动到回收站
            do {
                try await cloudHandler.moveFile(at: audio.url, to: trashUrl)
            } catch let e {
                print(e)
                os_log("\(Logger.isMain)☁️⚠️ CloudFile::trash \(e.localizedDescription)")
            }
        }
    }
    
    // MARK: 移除下载
    func evict(_ url: URL) {
        Task {
            try? await cloudHandler.evict(url: url)
        }
    }
}
