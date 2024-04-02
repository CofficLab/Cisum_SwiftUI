import Foundation
import OSLog

class SmartFile {
    var fileManager = FileManager.default
    var url: URL

    init(url: URL) {
        self.url = url
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
                os_log("\(Logger.isMain)☁️ CloudFile::copy 获取授权失败，可能不是用户选择的文件，直接复制 \(self.url.lastPathComponent)")
                try fileManager.copyItem(at: self.url, to: destnation)
            }
        } catch {
            os_log("\(Logger.isMain)☁️ SmartFile::复制文件发生错误 -> \(error.localizedDescription)")
        }
    }

    /// 下载文件
    func download() {
        do {
            try fileManager.startDownloadingUbiquitousItem(at: self.url)
            os_log("\(Logger.isMain)☁️ CloudFile::已触发下载 \(self.url.lastPathComponent)")
        } catch {
            os_log("\(Logger.isMain)☁️ CloudFile::下载文件出现错误\n\(error)")
        }
    }
}
