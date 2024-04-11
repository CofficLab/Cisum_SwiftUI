import AVFoundation
import Foundation
import OSLog
import SwiftData
import SwiftUI

@Model
class Audio {
    @Transient let fileManager = FileManager.default

    var url: URL
    var order: Int = Int.random(in: 0...500000000)
    var isPlaceholder: Bool = false
    var title: String = ""
    var playCount: Int = 0

    var size: Int64 { getFileSize() }
    var ext: String { url.pathExtension }
    var isSupported: Bool { AppConfig.supportedExtensions.contains(ext.lowercased()) }
    var isNotSupported: Bool { !isSupported }
    // 未解决的问题：ios上文件APP中能看到，但FileManager.default.exits返回false
    var isExists: Bool { fileManager.fileExists(atPath: url.path) || true}
    var isNotExists: Bool { !isExists }

    init(_ url: URL) {
        // os_log("\(Logger.isMain)🚩 AudioModel::init -> \(url.lastPathComponent)")
        self.url = url
        self.title = url.deletingPathExtension().lastPathComponent
    }

    func makeRandomOrder() {
        order = Int.random(in: 0...500000000)
    }

    func getFileSize() -> Int64 {
        if self.isNotExists {
            return 0
        }
        
        return FileHelper.getFileSize(url)
    }

    func getFileSizeReadable() -> String {
        if self.isNotExists {
            return "-"
        }
        
        return FileHelper.getFileSizeReadable(url)
    }

    func mergeWith(_ item: MetadataItemWrapper) -> Audio {
        isPlaceholder = item.isPlaceholder

        return self
    }

    static func fromMetaItem(_ item: MetadataItemWrapper) -> Audio? {
        guard let url = item.url else {
            return nil
        }

        let audio = Audio(url)

        return audio.mergeWith(item)
    }
}

// MARK: ID

extension Audio: Identifiable {
    var id: PersistentIdentifier { persistentModelID }
}

// MARK: iCloud 相关

extension Audio {
    var isDownloaded: Bool { iCloudHelper.isDownloaded(url: url) }
    var isNotDownloaded: Bool { !isDownloaded }
    var isDownloading: Bool { iCloudHelper.isDownloading(url) }
}

#Preview("App") {
    RootView {
        ContentView()
    }
    .modelContainer(AppConfig.getContainer())
}
