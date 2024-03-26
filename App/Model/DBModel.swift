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
            os_log("🍋 DBModel::创建 Audios 目录成功")
        } catch {
            os_log("创建 Audios 目录失败\n\(error.localizedDescription)")
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
        clearFolderContents(atPath: cloudDisk.path)
    }
    
    func clearFolderContents(atPath path: String) {
        let fileManager = FileManager.default
        do {
            let contents = try fileManager.contentsOfDirectory(atPath: path)
            for item in contents {
                let itemPath = URL(fileURLWithPath: path).appendingPathComponent(item).path
                try fileManager.removeItem(atPath: itemPath)
            }
        } catch {
            print("Error: \(error)")
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

        os_log("🏠 DBModel::total \(fileNames.count)，valid \(sortedFiles.count)")
        return sortedFiles
    }
}

#Preview {
    RootView {
        ContentView(play: false)
    }
}
