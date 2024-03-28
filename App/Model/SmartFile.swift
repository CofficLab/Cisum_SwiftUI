import Foundation
import OSLog

class SmartFile {
    var fileManager = FileManager.default
    var url: URL
    var timer: Timer?

    init(url: URL) {
        self.url = url
    }

    /// 删除
    func delete() {
        do {
            if self.fileManager.fileExists(atPath: self.url.path) {
                try self.fileManager.removeItem(at: self.url)
            } else {
                os_log("\(Logger.isMain)删除时发现文件不存在，忽略 -> \(self.url.lastPathComponent)")
            }
        } catch {
            os_log(.error, "删除文件失败\n\(error)")
        }
    }

    // 将文件复制到目的地
    func copyTo(destnation: URL) {
        os_log(
            "\(Logger.isMain)☁️ CloudFile::copy \(self.url.lastPathComponent) -> \(destnation.lastPathComponent)"
        )

        do {
            // 获取授权
            if self.url.startAccessingSecurityScopedResource() {
                os_log(
                    "\(Logger.isMain)☁️ CloudFile::copy获取授权后复制 \(self.url.lastPathComponent, privacy: .public)"
                )
                try FileManager.default.copyItem(at: self.url, to: destnation)
                self.url.stopAccessingSecurityScopedResource()
            } else {
                os_log("\(Logger.isMain)☁️ CloudFile::copy 获取授权失败，可能不是用户选择的文件，直接复制")
                os_log("\(Logger.isMain)☁️ CloudFile::copy \(self.url.lastPathComponent)")
                try FileManager.default.copyItem(at: self.url, to: destnation)
            }
        } catch {
            os_log("\(Logger.isMain)☁️ SmartFile::复制文件发生错误 -> \(error.localizedDescription)")
        }
    }

    /// 下载文件
    func download(completion: @escaping () -> Void) {
        // os_log("\(Logger.isMain)☁️ CloudFile::下载文件 -> \(self.url.lastPathComponent)")

        if iCloudHelper.isDownloaded(url: self.url) {
            //            os_log("\(Logger.isMain)☁️ CloudFile::已经下载了 🎉🎉🎉")
            completion()
            return
        }

        if iCloudHelper.isDownloading(self.url) {
            os_log("\(Logger.isMain)☁️ CloudFile::已在下载 \(self.url.lastPathComponent)")
            return
        } else {
            os_log("\(Logger.isMain)☁️ CloudFile::触发下载 \(self.url.lastPathComponent)")
        }

        do {
            try FileManager.default.startDownloadingUbiquitousItem(at: self.url)
        } catch {
            os_log("\(Logger.isMain)☁️ CloudFile::下载文件出现错误\n\(error)")

            completion()
            return
        }

        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [self] _ in
                if iCloudHelper.isDownloading(self.url) {
                    os_log("\(Logger.isMain)☁️ CloudFile::downloading \(self.url.lastPathComponent)")
                }

                if iCloudHelper.isDownloaded(url: self.url) {
                    // os_log("\(Logger.isMain)☁️ CloudFile::\(self.url.lastPathComponent) 下载完成 🎉🎉🎉")

                    self.timer?.invalidate()
                    completion()
                }
            }
        }
    }
}
