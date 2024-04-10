import Foundation

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
            SmartFile(url: url).copyTo(
                destnation: audiosDir.appendingPathComponent(url.lastPathComponent))
            completionOne(url)
        }

        completionAll()
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
            // 移动到回收站
            if audio.isExists {
                do {
                    try await cloudHandler.moveFile(at: audio.url, to: trashUrl)
                } catch let e {
                    print(e)
                }
            }
        }
    }
}
