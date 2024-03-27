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
    func copyTo(destnation: URL) {
        os_log("☁️ CloudFile::copy \(self.url.lastPathComponent) -> \(destnation.lastPathComponent)")

        do {
            // 获取授权
            if self.url.startAccessingSecurityScopedResource() {
                os_log("☁️ CloudFile::copy获取授权后复制 \(self.url.lastPathComponent, privacy: .public)")
                try FileManager.default.copyItem(at: self.url, to: destnation)
                self.url.stopAccessingSecurityScopedResource()
            } else {
                os_log("☁️ CloudFile::copy 获取授权失败，可能不是用户选择的文件，直接复制")
                os_log("☁️ CloudFile::copy \(self.url.lastPathComponent)")
                try FileManager.default.copyItem(at: self.url, to: destnation)
            }
        } catch {
            os_log("☁️ CloudFile::复制文件发生错误\n\(error)")
        }
    }

    /// 下载文件
    func download(completion: @escaping () -> Void) {
        //os_log("☁️ CloudFile::下载文件 -> \(self.url.lastPathComponent)")
        
        if iCloudHelper.isDownloaded(url: url) {
//            os_log("☁️ CloudFile::已经下载了 🎉🎉🎉")
            completion()
            return
        }
        
        if iCloudHelper.isDownloading(url) {
            os_log("☁️ CloudFile::已在下载 \(self.url.lastPathComponent)")
            return
        } else {
            os_log("☁️ CloudFile::触发下载 \(self.url.lastPathComponent)")
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
                if iCloudHelper.isDownloading(url) {
                    os_log("☁️ CloudFile::downloading \(self.url.lastPathComponent)")
                }

                if iCloudHelper.isDownloaded(url: url) {
                    //os_log("☁️ CloudFile::\(self.url.lastPathComponent) 下载完成 🎉🎉🎉")

                    self.timer?.invalidate()
                    completion()
                }
            }
        }
    }
}
