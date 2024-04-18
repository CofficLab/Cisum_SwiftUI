import Foundation
import OSLog
import SwiftData

class CopyFiles {
    var fileManager = FileManager.default
    var queue = DispatchQueue.global(qos: .background)
    var audiosDir = AppConfig.audiosDir
    
    func run(db: DB) throws {
        Task {
            let tasks = await db.allCopyTasks()
            queue.async {
                for task in tasks {
                    Task {
                        do {
                            await db.setTaskRunning(task)
                            try self.copyTo(url: task.url)
                            db.delete(task)
                        } catch let e {
                            await db.setTaskError(task, e)
                        }
                    }
                }
            }
        }
    }
    
    // 将文件复制到音频目录
    func copyTo(url: URL) throws {
        os_log(
            "\(Logger.isMain)📁 CopyFiles::copy \(url.lastPathComponent)"
        )
        
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
            os_log("\(Logger.isMain)📁 CopyFiles::copy  -> \(d.lastPathComponent)")
        }
        
        do {
            // 获取授权
            if url.startAccessingSecurityScopedResource() {
                os_log(
                    "\(Logger.isMain)📁 CopyFiles::copy 获取授权后复制 \(url.lastPathComponent, privacy: .public)"
                )
                try FileManager.default.copyItem(at: url, to: d)
                url.stopAccessingSecurityScopedResource()
            } else {
                os_log("\(Logger.isMain)📁 CopyFiles::copy 获取授权失败，可能不是用户选择的文件，直接复制 \(url.lastPathComponent)")
                try fileManager.copyItem(at: url, to: d)
            }
        } catch {
            os_log("\(Logger.isMain)📁 CopyFiles::复制文件发生错误 -> \(error.localizedDescription)")
            throw error
        }
    }
}
