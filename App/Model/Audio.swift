import AVFoundation
import CryptoKit
import Foundation
import OSLog
import SwiftData
import SwiftUI

@Model
class Audio {
    static var label = "🪖 Audio::"
    static var verbose = false

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
    // nil表示未计算过
    var size: Int64?
    var identifierKey: String?
    var contentType: String?

    // 新增字段记得设置默认值，否则低版本更新时崩溃

    var verbose: Bool { Self.verbose }
    var ext: String { url.pathExtension }
    var isSupported: Bool { AppConfig.supportedExtensions.contains(ext.lowercased()) }
    var isNotSupported: Bool { !isSupported }
    // 未解决的问题：ios上文件APP中能看到，但FileManager.default.exits返回false
    var isExists: Bool { fileManager.fileExists(atPath: url.path) || true }
    var isNotExists: Bool { !isExists }
    var dislike: Bool { !like }
    var label: String { "\(Logger.isMain)\(Self.label)" }

    init(_ url: URL,
         size: Int64? = nil,
         title: String? = nil,
         identifierKey: String? = nil,
         contentType: String? = nil)
    {
        if Self.verbose {
            os_log("\(Logger.isMain)\(Self.label)Init -> \(url.lastPathComponent)")
            print(" Title: \(title ?? "")")
            print(" Type: \(contentType ?? "")")
            print(" Size: \(String(describing: size))")
        }

        self.url = url
        self.order = Self.makeRandomOrder()
        self.identifierKey = identifierKey
        self.contentType = contentType
        self.title = url.deletingPathExtension().lastPathComponent

//        if let title = title {
//            self.title = title
//        }

        if let size = size {
            self.size = size
        } else {
            self.size = FileHelper.getFileSize(url)
        }
    }

    convenience init(_ metadataItem: MetadataItemWrapper) {
        self.init(metadataItem.url!,
                  size: metadataItem.fileSize != nil ? Int64(metadataItem.fileSize!) : nil,
                  title: metadataItem.fileName,
                  contentType: metadataItem.contentType)
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

extension Audio {
    func getFileSize() -> Int64 {
        if let size = self.size, size > 0 {
            return size
        }

        return FileHelper.getFileSize(url)
    }

    func getFileSizeReadable() -> String {
        FileHelper.getFileSizeReadable(getFileSize())
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
    func getHash(verbose: Bool = false) -> String {
        var fileHash = ""
        let startTime = DispatchTime.now()

        if verbose {
            if self.isDownloaded {
                os_log("\(self.label)GetHash -> \(self.title) -> Downloaded 👍👍👍")
            } else {
                os_log("\(self.label)GetHash -> \(self.title) -> Not Downloaded ☁️☁️☁️")
            }
        }

        if self.isNotDownloaded {
            return ""
        }

        fileHash = FileHelper.getHash(self.url)

        // 计算代码执行时间
        let nanoTime = DispatchTime.now().uptimeNanoseconds - startTime.uptimeNanoseconds
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
