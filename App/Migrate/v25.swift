import OSLog
import Foundation

extension Migrate {
    func migrateTo25(dataManager: DataManager) {
        os_log("\(self.label)版本升级 -> 2.5")
        
        let fileManager = FileManager.default
        
        guard let root = dataManager.disk.make(DiskScene.Music.folderName)?.root else {
            os_log("\(self.label)版本升级失败 -> 获取Music目录失败")
            return
        }
        
        guard let mountedURL = dataManager.disk.getMountedURL() else {
            os_log(.error, "\(self.label)版本升级失败 -> 获取Disk Mouted目录失败")
            return
        }
        
        do {
            let contents = try fileManager.contentsOfDirectory(at: mountedURL, includingPropertiesForKeys: [], options: .skipsHiddenFiles)
            
            for i in contents {
                if !DiskScene.allCases.map({
                    $0.folderName
                }).contains(i.lastPathComponent) {
                    moveTo(i, root.appendingPathComponent(i.lastPathComponent))
                }
            }
        } catch let e {
            os_log(.error, "\(self.label)版本升级失败 -> \(e.localizedDescription)")
        }
    }
    
    func moveTo(_ url: URL, _ t: URL) {
        os_log("\(self.label)Move \(url.lastPathComponent) -> \(t.lastPathComponent)")
        
        let fileManager = FileManager.default
        
        // 目的地已经存在同名文件
        var d = t
        var times = 1
        let fileName = url.deletingPathExtension().lastPathComponent
        let ext = url.pathExtension
        while fileManager.fileExists(atPath: d.path) {
            d = d.deletingLastPathComponent()
                .appendingPathComponent("\(fileName)-\(times)")
                .appendingPathExtension(ext)
            times += 1
            os_log("\(self.label)Move  -> \(d.lastPathComponent)")
        }
        
        do {
            // 获取授权
            if url.startAccessingSecurityScopedResource() {
                os_log(
                    "\(self.label)Move 获取授权后移动 \(url.lastPathComponent, privacy: .public)"
                )
                try FileManager.default.moveItem(at: url, to: d)
                url.stopAccessingSecurityScopedResource()
            } else {
                os_log("\(self.label)Move 获取授权失败，可能不是用户选择的文件，直接移动 \(url.lastPathComponent)")
                try fileManager.copyItem(at: url, to: d)
            }
        } catch {
            os_log(.error, "\(self.label)移动文件发生错误 -> \(error.localizedDescription)")
        }
    }
}
