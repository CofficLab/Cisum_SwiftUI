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
    
    // MARK: Descriptor
    
    static var descriptorAll = FetchDescriptor(predicate: #Predicate<Audio> { _ in
        return true
    }, sortBy: [
        SortDescriptor(\.order, order: .forward)
    ])
    
    static var descriptorNoGroup = FetchDescriptor(predicate: #Predicate<Audio> {
        $0.group == nil
    })
    
    static var descriptorFirst: FetchDescriptor<Audio> {
        var descriptor = Audio.descriptorAll
        descriptor.sortBy.append(.init(\.order, order: .forward))
        descriptor.fetchLimit = 1
        
        return descriptor
    }

    @Transient
    let fileManager = FileManager.default

    @Attribute(.unique)
    var url: URL

    var order: Int
    var isPlaceholder: Bool = false
    var like: Bool = false
    var title: String = ""
    var playCount: Int = 0
    // nil表示未计算过
    var size: Int64?
    var identifierKey: String?
    var contentType: String?
    // nil表示未计算过，true表示有，false表示没有
    var hasCover: Bool? = nil
    
    // MARK: Relationship
    
    @Relationship(deleteRule: .nullify, inverse: \AudioGroup.audios)
    var group: AudioGroup? = nil

    // 新增字段记得设置默认值，否则低版本更新时崩溃

    var verbose: Bool { Self.verbose }
    var ext: String { url.pathExtension }
    var isSupported: Bool { Config.supportedExtensions.contains(ext.lowercased()) }
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

    convenience init(_ metadataItem: MetaWrapper) {
        self.init(metadataItem.url!,
                  size: metadataItem.fileSize != nil ? Int64(metadataItem.fileSize!) : nil,
                  title: metadataItem.fileName,
                  contentType: metadataItem.contentType)
    }
}

// MARK: MetaItem

extension Audio {
    func mergeWith(_ item: MetaWrapper) -> Audio {
        self.isPlaceholder = item.isPlaceholder
        self.contentType = item.contentType

        return self
    }

    static func fromMetaItem(_ item: MetaWrapper) -> Audio? {
        guard let url = item.url else {
            return nil
        }

        let audio = Audio(url)

        return audio.mergeWith(item)
    }
}

// MARK: FileSize

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
    func getHash(verbose: Bool = true) -> String {
        FileHelper.getMD5(self.url)
    }
}

// MARK: iCloud 相关

extension Audio {
    func checkIfDownloaded() -> Bool { iCloudHelper.isDownloaded(url: url) }
    func checkIfDownloading() -> Bool { iCloudHelper.isDownloading(url) }
    func checkIfNotDownloaded() -> Bool { self.checkIfDownloaded() == false }
    
    var isDownloaded: Bool {
        checkIfDownloaded()
    }
    
    var isDownloading: Bool {
        checkIfDownloading()
    }
    
    var isNotDownloaded: Bool {
        !isDownloaded
    }
}

extension Audio {
    func toPlayAsset() -> PlayAsset {
        PlayAsset(url: self.url)
    }
    
    static func fromPlayAsset(_ asset: PlayAsset) -> Audio {
        Audio(asset.url)
    }
}

#Preview("App") {
    RootView {
        ContentView()
    }
    .modelContainer(Config.getContainer)
}
