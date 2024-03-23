import Foundation
import OSLog

class DatabaseManager: ObservableObject {
    @Published private(set) var files: [URL] = []
    @Published private(set) var audios: [AudioModel] = []

    static var shared: DatabaseManager = DatabaseManager(rootDir: DatabaseManager.getiCloudDocumentsUrl())

    var rootDir: URL

    init(rootDir: URL) {
        AppConfig.logger.databaseManager.debugEvent("初始化")
        self.rootDir = rootDir
        refresh()
    }

    static func getiCloudDocumentsUrl() -> URL {
        let fileManager = FileManager.default

        if fileManager.ubiquityIdentityToken != nil {
            return fileManager.url(forUbiquityContainerIdentifier: Config.Container)!.appendingPathComponent("Documents")
        } else {
            AppConfig.logger.databaseManager.debugSomething("不支持 iCloud，使用本地目录")

            return Config.DocumentsDir
        }
    }

    func deleteOne(url: URL) {
        AppConfig.logger.databaseManager.debugEvent("删除\n\(url.lastPathComponent)")
        do {
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            } else {
                AppConfig.logger.databaseManager.warning("删除时发现文件不存在，忽略\n\(url.lastPathComponent)")
            }
        } catch {
            AppConfig.logger.app.e("删除文件失败\n\(error)")
        }

        refresh()
    }

    func addFile(_ url: URL) {
        let destinationURL = rootDir.appendingPathComponent(url.lastPathComponent)
        AppConfig.logger.app.debugSomething("复制文件：\n \(url.lastPathComponent)")

        do {
            if url.startAccessingSecurityScopedResource() {
                try FileManager.default.copyItem(at: url, to: destinationURL)
                do { url.stopAccessingSecurityScopedResource() }
            } else {
                AppConfig.logger.app.e("复制文件时 url.startAccessingSecurityScopedResource 发生错误")
            }
        } catch {
            AppConfig.logger.app.e("复制文件发生错误\n\(error)")
        }
        
        refresh()
    }
    
    private func getFiles() -> [URL] {
        let fileManager = FileManager.default
        let fileNames = try! fileManager.contentsOfDirectory(at: rootDir, includingPropertiesForKeys: nil)

        let sortedFiles = fileNames.sorted {
            $0.lastPathComponent.localizedCaseInsensitiveCompare($1.lastPathComponent) == .orderedAscending
        }.filter {
            isAudioFile(url: $0)
        }

        AppConfig.logger.databaseManager.debugSomething("文件\(fileNames.count)，有效\(sortedFiles.count)\n\(sortedFiles.map { $0.lastPathComponent }.prefix(3).joined(separator: "\n"))\n...")

        // 如果是 iCloud 文件，触发下载
        let iCloudAudioFiles = fileNames.filter { isAudioiCloudFile(url: $0) }
        for iCloudAudioFile in iCloudAudioFiles {
            AppConfig.logger.app.debugEvent("下载 iCloud 文件：\n\(iCloudAudioFile.lastPathComponent)")
            do {
                try fileManager.startDownloadingUbiquitousItem(at: iCloudAudioFile)
            } catch {
                AppConfig.logger.app.e("下载 iCloud 文件错误\n\(error)")
            }
        }

        return sortedFiles
    }
    
    private func refresh() {
        self.files = getFiles()
        self.audios = files.map { AudioModel.fromUrl(url: $0) }
    }
}
