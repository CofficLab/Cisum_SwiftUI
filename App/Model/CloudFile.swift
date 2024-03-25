import Foundation
import OSLog

class CloudFile {
    var fileManager = FileManager.default
    var url: URL
    var timer: Timer?

    init(url: URL) {
        self.url = url
    }

    /// 从 iCloud 删除
    func delete() {
        do {
            if fileManager.fileExists(atPath: url.path) {
                try fileManager.removeItem(at: url)
            } else {
                os_log("删除时发现文件不存在，忽略 -> \(self.url.lastPathComponent)")
            }
        } catch {
            os_log(.error, "删除文件失败\n\(error)")
        }
    }

    // 将文件复制到目的地
    //  如果文件尚未下载到磁盘
    //  先在目的地创建一个临时文件
    //  下载并复制完后删除临时文件
    func copyTo(to: URL, completion: @escaping (_ sourceUrl:URL) -> Void = {url in }) {
        os_log("☁️ CloudFile::copy \(self.url.lastPathComponent) -> \(to.lastPathComponent)")
        createTempFile(to)
        download(completion: {
            do {
                // 获取授权
                if self.url.startAccessingSecurityScopedResource() {
                    os_log("☁️ CloudFile::copy获取授权后复制 \(self.url.lastPathComponent, privacy: .public)")
                    try FileManager.default.copyItem(at: self.url, to: to)
                    self.url.stopAccessingSecurityScopedResource()
                } else {
                    // 获取授权失败，可能不是用户选择的文件，直接复制
                    os_log("☁️ CloudFile::copy直接复制 \(self.url.lastPathComponent, privacy: .public)")
                    try FileManager.default.copyItem(at: self.url, to: to)
                }
            } catch {
                os_log("☁️ CloudFile::复制文件发生错误\n\(error)")
            }

            completion(self.url)
            self.deleteTempFile(to)
        })
    }

    func download(completion: @escaping () -> Void) {
        os_log("☁️ CloudFile::下载文件 -> \(self.url.lastPathComponent)")
        if iCloudHelper.isDownloaded(url: url) {
            os_log("☁️ CloudFile::已经下载了 🎉🎉🎉")
            completion()
            return
        }

        do {
            try FileManager.default.startDownloadingUbiquitousItem(at: url)
        } catch {
            os_log("☁️ CloudFile::下载文件出现错误\n\(error)")

            completion()
            return
        }

        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [self] _ in
                os_log("\(self.url.lastPathComponent) 现在状态是:\(iCloudHelper.getDownloadingStatus(url: self.url).rawValue)")

                if iCloudHelper.isDownloaded(url: url) {
                    os_log("\(self.url.lastPathComponent) 下载完成")

                    self.timer?.invalidate()
                    completion()
                }
            }
        }
    }
    
    private func deleteTempFile(_ url: URL) {
        do {
            try FileManager.default.removeItem(at: getTempFileUrl(url))
        } catch {
            AppConfig.logger.app.error("删除临时文件失败")
        }
    }

    private func createTempFile(_ url: URL) {
        let content = url.absoluteString
        let tempFileUrl = getTempFileUrl(url)
        
        do {
            try content.write(to: tempFileUrl, atomically: true, encoding: .utf8)
        } catch {
            os_log("☁️ CloudFile::写入临时文件失败\n\(error)")
        }
    }

    private func getTempFileUrl(_ url: URL) -> URL {
        return url.appendingPathExtension("downloading")
    }
}
