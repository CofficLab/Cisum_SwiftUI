import AVFoundation
import CryptoKit
import Foundation
import OSLog
import SwiftData
import SwiftUI

/* 存储音频数据，尤其是将计算出来的属性存储下来 */

@Model
class Audio: FileBox {
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

        if let size = size {
            self.size = size
        } else {
            self.size = FileHelper.getFileSize(url)
        }
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

// MARK: Transform

extension Audio {
    func toPlayAsset() -> PlayAsset {
        PlayAsset(url: self.url, size: size)
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
