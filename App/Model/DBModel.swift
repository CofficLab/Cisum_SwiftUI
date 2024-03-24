import Foundation
import OSLog

class DBModel {
    var fileManager = FileManager.default
    var queue = DispatchQueue.global()
    var rootDir: URL
    var timer: Timer?

    init(rootDir: URL) {
        os_log("初始化 DatabaseModel")
        
        self.rootDir = rootDir.appendingPathComponent(AppConfig.audiosDirName)
        do {
            try fileManager.createDirectory(at: self.rootDir, withIntermediateDirectories: true)
            AppConfig.logger.databaseModel.info("创建 Audios 目录成功")
        } catch {
            AppConfig.logger.databaseModel.error("创建 Audios 目录失败\n\(error.localizedDescription)")
        }
    }

    /// 删除多个文件
    func delete(urls: Set<URL>) async {
        queue.async {
            for url in urls {
                CloudFile(url: url).delete()
            }
        }
    }

    func add(_ urls: [URL], completionAll: @escaping () -> Void, completionOne: @escaping (_ sourceUrl: URL) -> Void = { _ in }) {
        AppConfig.bgQueue.async {
            if urls.count == 1 {
                AppConfig.logger.databaseModel.info("复制 \(urls.first!.lastPathComponent, privacy: .public)")
            } else {
                AppConfig.logger.databaseModel.info("复制 \(urls.count, privacy: .public) 个文件")
            }

//            let dispatchGroup = DispatchGroup()
            for url in urls {
//                dispatchGroup.enter()
                CloudFile(url: url).copyTo(to: self.rootDir.appendingPathComponent(url.lastPathComponent), completion: { url in
//                    dispatchGroup.leave()
                    completionOne(url)
                })
            }

//            dispatchGroup.notify(queue: .main) {
            // 这里的代码会在全部copyFile完成后执行
            completionAll()
//            }
        }
    }

    func downloadOne(_ url: URL) -> Bool {
        CloudFile(url: url).download {
        }

        return true
    }

    func getFiles() -> [URL] {
        var fileNames: [URL] = []

        do {
            try fileNames = AppConfig.fileManager.contentsOfDirectory(at: rootDir, includingPropertiesForKeys: nil)
        } catch let error {
            AppConfig.logger.databaseModel.error("读取目录发生错误，目录是\n\(self.rootDir)\n\(error)")
        }

        let sortedFiles = fileNames.sorted {
            $0.lastPathComponent.localizedCaseInsensitiveCompare($1.lastPathComponent) == .orderedAscending
        }.filter {
            FileHelper.isAudioFile(url: $0) || $0.pathExtension == "downloading"
        }

        AppConfig.logger.databaseModel.info("文件\(fileNames.count)，有效\(sortedFiles.count)")

        // 如果是 iCloud 文件，触发下载
        let iCloudAudioFiles = fileNames.filter { FileHelper.isAudioiCloudFile(url: $0) }
        for iCloudAudioFile in iCloudAudioFiles {
            AppConfig.logger.databaseModel.info("下载 iCloud 文件：\n\(iCloudAudioFile.lastPathComponent)")
            do {
                try AppConfig.fileManager.startDownloadingUbiquitousItem(at: iCloudAudioFile)
            } catch {
                AppConfig.logger.databaseModel.error("下载 iCloud 文件错误\n\(error)")
            }
        }

        AppConfig.logger.databaseModel.debug("获取文件完成，共 \(sortedFiles.count) 个")
        return sortedFiles
    }
}
