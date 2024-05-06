import AVFoundation
import CryptoKit
import Foundation
import OSLog
import SwiftData
import SwiftUI

@Model
class Audio {
    @Transient let fileManager = FileManager.default

    var url: URL
    var order: Int
    var isPlaceholder: Bool = false
    var like: Bool = false
    var title: String = ""
    var playCount: Int = 0
    var fileHash: String = ""
    var duplicatedOf: URL? = nil
    var duplicateIds: [Audio.ID] = []

    var size: Int64 { getFileSize() }
    var ext: String { url.pathExtension }
    var isSupported: Bool { AppConfig.supportedExtensions.contains(ext.lowercased()) }
    var isNotSupported: Bool { !isSupported }
    // 未解决的问题：ios上文件APP中能看到，但FileManager.default.exits返回false
    var isExists: Bool { fileManager.fileExists(atPath: url.path) || true }
    var isNotExists: Bool { !isExists }
    var dislike: Bool { !like }

    init(_ url: URL) {
        // os_log("\(Logger.isMain)🚩 AudioModel::init -> \(url.lastPathComponent)")
        self.url = url
        self.title = url.deletingPathExtension().lastPathComponent
        self.order = Self.makeRandomOrder()
        self.fileHash = getHash()
    }

    static func makeRandomOrder() -> Int {
        Int.random(in: 101 ... 500000000)
    }

    func randomOrder() {
//        os_log("\(Logger.isMain)🚩 AudioModel::randomOrder -> \(self.title)")
        order = Self.makeRandomOrder()
    }

    func getFileSize() -> Int64 {
        if isNotExists {
            return 0
        }

        return FileHelper.getFileSize(url)
    }

    func getFileSizeReadable() -> String {
        if isNotExists {
            return "-"
        }

        return FileHelper.getFileSizeReadable(url)
    }

    func mergeWith(_ item: MetadataItemWrapper) -> Audio {
        isPlaceholder = item.isPlaceholder

        return self
    }

    func getDuplicates(_ db: DB) async -> [Audio] {
        var audios: [Audio] = []
        for duplicateId in self.duplicateIds {
            if let a: Audio = await db.findAudio(duplicateId) {
                audios.append(a)
            }
        }

        return audios
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

// MARK: HASH

extension Audio {
    func getHash() -> String {
        do {
            let fileData = try Data(contentsOf: URL(fileURLWithPath: self.url.path))
            let hash = SHA256.hash(data: fileData)

            return hash.compactMap { String(format: "%02x", $0) }.joined()
        } catch {
            print("Error calculating file hash: \(error)")
            return "-"
        }
    }
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
