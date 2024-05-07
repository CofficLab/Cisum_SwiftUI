import Foundation
import OSLog

class DiskiCloud: ObservableObject {
    var fileManager = FileManager.default
    var cloudHandler = CloudHandler()
    var audiosDir: URL = AppConfig.audiosDir
    var bg = AppConfig.bgQueue
    var label = "🗄️ DBFolder::"
    var verbose = false
    
    func trash(_ audio: Audio) async {
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
        
        // 文件不存在
        if !fileManager.fileExists(atPath: audio.url.path) {
            return
        }
            
        // 移动到回收站
        do {
            try await cloudHandler.moveFile(at: audio.url, to: trashUrl)
        } catch let e {
            os_log(.error, "\(Logger.isMain)☁️⚠️ CloudFile::trash \(e.localizedDescription)")
        }
    }
}

extension DiskiCloud: DiskContact {
    func clearFolderContents(atPath path: String) {
        let fileManager = FileManager.default
        do {
            let contents = try fileManager.contentsOfDirectory(atPath: path)
            for item in contents {
                let itemPath = URL(fileURLWithPath: path).appendingPathComponent(item).path
                try fileManager.removeItem(atPath: itemPath)
            }
        } catch {
            os_log("\(Logger.isMain)\(self.label)clearFolderContents error: \(error.localizedDescription)")
        }
    }
    
    func deleteFile(_ audio: Audio) throws {
        if verbose {
            os_log("\(Logger.isMain)\(self.label)删除 \(audio.url)")
        }
        
        if fileManager.fileExists(atPath: audio.url.path) == false {
            return
        }
        
        try fileManager.removeItem(at: audio.url)
    }
    
    // MARK: 移除下载

    func evict(_ url: URL) {
        Task {
            try? await cloudHandler.evict(url: url)
        }
    }
    
    func download(_ audio: Audio) {
        if audio.isNotExists {
            return
        }
        
        if audio.isDownloaded {
            return
        }
        
        Task {
            os_log("\(self.label)Download \(audio.title)")
            do {
                try await cloudHandler.download(url: audio.url)
            } catch let e {
                print(e)
            }
        }
    }

    // MARK: 将文件复制到音频目录
    func copyTo(url: URL) throws {
        os_log("\(self.label)copy \(url.lastPathComponent)")
        
        // 目的地已经存在同名文件
        var d = audiosDir.appendingPathComponent(url.lastPathComponent)
        var times = 1
        let fileName = url.deletingPathExtension().lastPathComponent
        let ext = url.pathExtension
        while fileManager.fileExists(atPath: d.path) {
            d = d.deletingLastPathComponent()
                .appendingPathComponent("\(fileName)-\(times)")
                .appendingPathExtension(ext)
            times += 1
            os_log("\(self.label)copy  -> \(d.lastPathComponent)")
        }
        
        do {
            // 获取授权
            if url.startAccessingSecurityScopedResource() {
                os_log(
                    "\(self.label)copy 获取授权后复制 \(url.lastPathComponent, privacy: .public)"
                )
                try FileManager.default.copyItem(at: url, to: d)
                url.stopAccessingSecurityScopedResource()
            } else {
                os_log("\(self.label)copy 获取授权失败，可能不是用户选择的文件，直接复制 \(url.lastPathComponent)")
                try fileManager.copyItem(at: url, to: d)
            }
        } catch {
            os_log("\(self.label)复制文件发生错误 -> \(error.localizedDescription)")
            throw error
        }
    }
}
