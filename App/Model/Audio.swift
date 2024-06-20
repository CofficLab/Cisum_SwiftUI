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
    
    static var descriptorFirst: FetchDescriptor<Audio> {
        var descriptor = Audio.descriptorAll
        descriptor.sortBy.append(.init(\.order, order: .forward))
        descriptor.fetchLimit = 1
        
        return descriptor
    }

    @Transient
    let fileManager = FileManager.default
    
    // MARK: 字段

    @Attribute(.unique)
    var url: URL
    var order: Int
    var isPlaceholder: Bool = false
    var like: Bool = false
    var title: String = ""
    var playCount: Int = 0
    var size: Int64?
    var identifierKey: String?
    var contentType: String?
    var hasCover: Bool? = nil
    var fileHash: String? = nil

    // 新增字段记得设置默认值，否则低版本更新时崩溃

    var verbose: Bool { Self.verbose }
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
    var isDownloaded: Bool {
        iCloudHelper.isDownloaded(url)
    }
    
    var isDownloading: Bool {
        iCloudHelper.isDownloading(url)
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
