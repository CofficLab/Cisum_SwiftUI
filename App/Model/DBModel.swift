import Foundation
import OSLog
import SwiftUI

class DBModel {
    var fileManager = FileManager.default
    var queue = DispatchQueue.global()
    var timer: Timer?
    
    /// 云盘目录，用来同步
    var cloudDisk: URL
    
    /// 本地磁盘目录，用来存放缓存
    var localDisk: URL?

    init(cloudDisk: URL, localDisk: URL? = nil) {
        os_log("初始化 DatabaseModel")

        self.cloudDisk = cloudDisk.appendingPathComponent(AppConfig.audiosDirName)
        self.localDisk = localDisk
        
        do {
            try fileManager.createDirectory(at: self.cloudDisk, withIntermediateDirectories: true)
            AppConfig.logger.databaseModel.info("创建 Audios 目录成功")
        } catch {
            AppConfig.logger.databaseModel.error("创建 Audios 目录失败\n\(error.localizedDescription)")
        }
    }

    /// 删除多个文件
    func delete(urls: Set<URL>) async {
        os_log("DBModel::delete")
        queue.async {
            for url in urls {
                self.deleteCache(url)
                CloudFile(url: url).delete()
            }
        }
    }

    /// 往数据库添加文件
    func add(_ urls: [URL], completionAll: @escaping () -> Void, completionOne: @escaping (_ sourceUrl: URL) -> Void = { _ in }) {
        queue.async {
            for url in urls {
                self.saveToCache(url)
                CloudFile(url: url).copyTo(to: self.cloudDisk.appendingPathComponent(url.lastPathComponent), completion: { url in
                    completionOne(url)
                })
            }

            completionAll()
        }
    }

    func downloadOne(_ url: URL) -> Bool {
        CloudFile(url: url).download {
        }

        return true
    }

    /// 获取目录里的文件列表
    func getFiles() -> [URL] {
        var fileNames: [URL] = []

        do {
            try fileNames = fileManager.contentsOfDirectory(at: cloudDisk, includingPropertiesForKeys: nil)
        } catch let error {
            os_log("读取目录发生错误，目录是\n\(self.cloudDisk)\n\(error)")
        }

        // 处理得到的文件
        //  排序
        //  只需要音频文件
        let sortedFiles = fileNames.sorted {
            $0.lastPathComponent.localizedCaseInsensitiveCompare($1.lastPathComponent) == .orderedAscending
        }.filter {
            FileHelper.isAudioFile(url: $0) || $0.pathExtension == "downloading"
        }

        os_log("文件\(fileNames.count)，有效\(sortedFiles.count)")

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

// MARK: 缓存

extension DBModel {
    var cacheDirName: String { AppConfig.cacheDirName }
    
    var cacheDir: URL? {
        guard let localDisk = localDisk else {
            return nil
        }
        
        let url = localDisk.appending(component: cacheDirName)
        
        var isDirectory: ObjCBool = true
        if !fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory) {
            do {
                try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
                os_log("创建缓存目录成功")
            } catch {
                os_log(.error, "创建缓存目录失败\n\(error.localizedDescription)")
            }
            
        }
        
        //os_log("缓存目录 -> \(url.absoluteString)")

        return url
    }

    func getCachePath(_ url: URL) -> URL? {
        cacheDir?.appendingPathComponent(url.lastPathComponent)
    }

    func saveToCache(_ url: URL) {
        guard let cachePath = getCachePath(url) else {
            return
        }
        
        do {
            try fileManager.copyItem(at: url, to: cachePath)
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }
    }
    
    /// 如果缓存了，返回缓存的URL，否则返回原来的
    func ifCached(_ url: URL) -> URL {
        if isCached(url) {
            return getCachePath(url) ?? url
        }
        
        return url
    }

    func isCached(_ url: URL) -> Bool {
        guard let cachePath = getCachePath(url) else {
            return false
        }
        
        os_log("DBModel::isCached -> \(cachePath.absoluteString)")
        return fileManager.fileExists(atPath: cachePath.path)
    }
    
    func deleteCache(_ url: URL) {
        os_log("DBModel::deleteCache")
        if isCached(url), let cachedPath = getCachePath(url) {
            os_log("DBModel::deleteCache -> delete")
            try? fileManager.removeItem(at: cachedPath)
        }
    }
}

// MARK: AudioModel 操作

extension DBModel {
    func getAudioModels() -> [AudioModel] {
        self.getFiles().map{
            if isCached($0) {
                return AudioModel($0, cacheURL: getCachePath($0))
            }
            
            return AudioModel($0)
        }
    }
}

#Preview {
    RootView {
        ContentView(play: false)
    }
}
