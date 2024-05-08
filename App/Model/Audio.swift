import AVFoundation
import CryptoKit
import Foundation
import OSLog
import SwiftData
import SwiftUI

@Model
class Audio {
    static var label = "🪖 Audio::"
    static var verbose = true
    
    @Transient
    let fileManager = FileManager.default

    @Attribute(.unique)
    var url: URL

    var order: Int
    var isPlaceholder: Bool = false
    var like: Bool = false
    var title: String = ""
    var playCount: Int = 0
    var fileHash: String = ""
    var duplicatedOf: URL?
    
    var verbose: Bool { Self.verbose }
    var size: Int64 { getFileSize() }
    var ext: String { url.pathExtension }
    var isSupported: Bool { AppConfig.supportedExtensions.contains(ext.lowercased()) }
    var isNotSupported: Bool { !isSupported }
    // 未解决的问题：ios上文件APP中能看到，但FileManager.default.exits返回false
    var isExists: Bool { fileManager.fileExists(atPath: url.path) || true }
    var isNotExists: Bool { !isExists }
    var dislike: Bool { !like }
    var label: String { "\(Logger.isMain)\(Self.label)" }

    init(_ url: URL) {
        if Self.verbose {
            //os_log("\(Logger.isMain)\(Self.label)Init -> \(url.lastPathComponent)")
        }
        
        self.url = url
        self.title = url.deletingPathExtension().lastPathComponent
        self.order = Self.makeRandomOrder()

        // 计算FileHash需要较长时间，放到后台任务
        if self.isNotDownloaded {
            self.fileHash = ""
        } else {
            //self.fileHash = getHash()
        }
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

    static func fromMetaItem(_ item: MetadataItemWrapper) -> Audio? {
        guard let url = item.url else {
            return nil
        }

        let audio = Audio(url)

        return audio.mergeWith(item)
    }
}

// MARK: Order

extension Audio {
    static func makeRandomOrder() -> Int {
        Int.random(in: 101 ... 500000000)
    }

    func randomOrder() {
        order = Self.makeRandomOrder()
    }
}

// MARK: ID

extension Audio: Identifiable {
    var id: PersistentIdentifier { persistentModelID }
}

// MARK: HASH

extension Audio {
    func getHash() -> String {
        var fileHash = ""
        let startTime = DispatchTime.now()
        
        if verbose {
            if self.isDownloaded {
                //os_log("\(self.label)GetHash -> \(self.title) -> Downloaded 👍👍👍")
            } else {
                os_log("\(self.label)GetHash -> \(self.title) -> Not Downloaded ☁️☁️☁️")
            }
        }

        // 如果文件尚未下载，会卡住，直到下载完成
        do {
            let fileData = try Data(contentsOf: URL(fileURLWithPath: self.url.path))
            let hash = SHA256.hash(data: fileData)
            fileHash = hash.compactMap { String(format: "%02x", $0) }.joined()
        } catch {
            print("Error calculating file hash: \(error)")
        }
        
        let endTime = DispatchTime.now()
        
        // 计算代码执行时间
        let nanoTime = endTime.uptimeNanoseconds - startTime.uptimeNanoseconds
        let timeInterval = Double(nanoTime) / 1_000_000_000
        
        if verbose {
            os_log("\(self.label)GetHash -> \(self.title) -> \(timeInterval) 秒 🎉🎉🎉")
        }
        
        return fileHash
    }
}

// MARK: iCloud 相关

extension Audio {
    var isDownloaded: Bool { iCloudHelper.isDownloaded(url: url) }
    var isNotDownloaded: Bool { !isDownloaded }
    var isDownloading: Bool { iCloudHelper.isDownloading(url) }
}

// MARK: Duplicates

extension Audio {
    func getDuplicates(_ db: DB) async -> [Audio] {
        await db.findDuplicates(self)
    }
}

#Preview("App") {
    RootView {
        ContentView()
    }
    .modelContainer(AppConfig.getContainer())
}
