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
                os_log("删除时发现文件不存在，忽略\n\(self.url.lastPathComponent)")
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
        createTempFile(to)
        download(completion: {
            do {
                // 获取授权
                if self.url.startAccessingSecurityScopedResource() {
                    // AppConfig.logger.databaseModel.info("获取授权后复制 \(url.lastPathComponent, privacy: .public)")
                    try FileManager.default.copyItem(at: self.url, to: to)
                    self.url.stopAccessingSecurityScopedResource()
                } else {
                    // 获取授权失败，可能不是用户选择的文件，直接复制
                    // AppConfig.logger.databaseModel.info("直接复制 \(url.lastPathComponent, privacy: .public)")
                    try FileManager.default.copyItem(at: self.url, to: to)
                }
            } catch {
                AppConfig.logger.databaseModel.error("复制文件发生错误\n\(error)")
            }

            completion(self.url)
            self.deleteTempFile(to)
        })
    }

    func download(completion: @escaping () -> Void) {
        // AppConfig.logger.databaseModel.info("下载文件")
        if iCloudHelper.isDownloaded(url: url) {
            // AppConfig.logger.databaseManager.info("已经下载了")
            completion()
            return
        }

        do {
            try FileManager.default.startDownloadingUbiquitousItem(at: url)
        } catch {
            AppConfig.logger.databaseModel.error("下载文件出现错误\n\(error)")

            completion()
            return
        }

//        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [self] _ in
                AppConfig.logger.databaseModel.debug("\(self.url.lastPathComponent, privacy: .public) 现在状态是:\n\(iCloudHelper.getDownloadingStatus(url: self.url).rawValue, privacy: .public)")

                if iCloudHelper.isDownloaded(url: url) {
                    AppConfig.logger.databaseModel.info("\(self.url.lastPathComponent, privacy: .public) 下载完成")

                    self.timer?.invalidate()
                    completion()
                }
            }
//        }
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
            AppConfig.logger.app.debug("写入临时文件失败\n\(error)")
        }
    }

    private func getTempFileUrl(_ url: URL) -> URL {
        return url.appendingPathExtension("downloading")
    }
}
