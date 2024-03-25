import Foundation
import OSLog
import SwiftUI

class DBModel {
    var fileManager = FileManager.default
    var queue = DispatchQueue.global()
    var timer: Timer?
    var cloudDisk: URL

    init(cloudDisk: URL) {
        os_log("🚩 初始化 DBModel")

        self.cloudDisk = cloudDisk.appendingPathComponent(AppConfig.audiosDirName)
        
        do {
            try fileManager.createDirectory(at: self.cloudDisk, withIntermediateDirectories: true)
            AppConfig.logger.databaseModel.info("创建 Audios 目录成功")
        } catch {
            AppConfig.logger.databaseModel.error("创建 Audios 目录失败\n\(error.localizedDescription)")
        }
    }
}

// MARK: 增删改查

extension DBModel {
    // MARK: 增加
    /// 往数据库添加文件
    func add(
        _ urls: [URL],
        completionAll: @escaping () -> Void,
        completionOne: @escaping (_ sourceUrl: URL) -> Void,
        onStart: @escaping (_ url: URL) -> Void
    ) {
        queue.async {
            for url in urls {
                onStart(url)
                CloudFile(url: url).copyTo(to: self.cloudDisk.appendingPathComponent(url.lastPathComponent), completion: { url in
                    completionOne(url)
                })
            }

            completionAll()
        }
    }
    
    // MARK: 删除
    
    /// 清空数据库
    func destroy() {
        do {
            try fileManager.removeItem(at: cloudDisk)
        } catch let e {
            os_log("\(e.localizedDescription)")
        }
    }
    
    // MARK: 查询
    
    func getAudioModels() -> [AudioModel] {
        self.getFiles().map{
            return AudioModel($0)
        }
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

        AppConfig.logger.databaseModel.debug("获取文件完成，共 \(sortedFiles.count) 个")
        return sortedFiles
    }
}

#Preview {
    RootView {
        ContentView(play: false)
    }
}
