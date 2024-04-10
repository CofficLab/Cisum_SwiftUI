import Foundation
import OSLog

class DBFolder: ObservableObject {
    var fileManager = FileManager.default
    var cloudHandler = CloudHandler()
    var audiosDir: URL = AppConfig.audiosDir
    
    /// 往目录添加文件
    func add(
        _ urls: [URL],
        completionAll: @escaping () -> Void,
        completionOne: @escaping (_ sourceUrl: URL) -> Void,
        onStart: @escaping (_ audio: Audio) -> Void
    ) {
        for url in urls {
            onStart(Audio(url))
            
            add(url, completion: {
                completionOne(url)
            })
        }

        completionAll()
    }
    
    /// 往目录添加文件
    func add(
        _ url: URL,
        completion: @escaping () -> Void
    ) {
        if iCloudHelper.isCloudPath(url: url) {
            copyTo(url: url,
                   destnation: audiosDir.appendingPathComponent(url.lastPathComponent))
        } else {
            copyTo(url: url,
                   destnation: audiosDir.appendingPathComponent(url.lastPathComponent))
        }
            
        completion()
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
    
    // 将文件复制到目的地
    func copyTo(url: URL, destnation: URL) {
        os_log(
            "\(Logger.isMain)☁️ CloudFile::copy \(url.lastPathComponent) -> \(destnation.lastPathComponent)"
        )

        do {
            // 获取授权
            if url.startAccessingSecurityScopedResource() {
                os_log(
                    "\(Logger.isMain)☁️ CloudFile::copy 获取授权后复制 \(url.lastPathComponent, privacy: .public)"
                )
                try FileManager.default.copyItem(at: url, to: destnation)
                url.stopAccessingSecurityScopedResource()
            } else {
                os_log("\(Logger.isMain)☁️ CloudFile::copy 获取授权失败，可能不是用户选择的文件，直接复制 \(url.lastPathComponent)")
                try fileManager.copyItem(at: url, to: destnation)
            }
        } catch {
            os_log("\(Logger.isMain)☁️ SmartFile::复制文件发生错误 -> \(error.localizedDescription)")
        }
    }
    
    // MARK: 移除下载
    func evict(_ url: URL) {
        Task {
            try? await cloudHandler.evict(url: url)
        }
    }
}
