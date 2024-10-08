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
    
    static var descriptorNotFolder = FetchDescriptor(predicate: predicateNotFolder, sortBy: [
        SortDescriptor(\.order, order: .forward)
    ])

    static var predicateNotFolder = #Predicate<Audio> { audio in
        audio.isFolder == false
    }
    
    static var descriptorFirst: FetchDescriptor<Audio> {
        var descriptor = Audio.descriptorAll
        descriptor.sortBy.append(.init(\.order, order: .forward))
        descriptor.fetchLimit = 1
        
        return descriptor
    }

    @Transient
    let fileManager = FileManager.default
    
    // MARK: Properties
    
    // 新增字段记得设置默认值，否则低版本更新时崩溃

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
    var isFolder: Bool = false

    var verbose: Bool { Self.verbose }
    var dislike: Bool { !like }
    var label: String { "\(Logger.isMain)\(Self.label)" }
    var children: [Audio]? {
        if url == .applicationDirectory {
            return nil
        }
        
        return [Audio(.applicationDirectory)]
    }

    init(_ url: URL,
         size: Int64? = nil,
         title: String? = nil,
         identifierKey: String? = nil,
         contentType: String? = nil,
         isFolder: Bool = false
    ) {
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
    func toPlayAsset(verbose: Bool = false) -> PlayAsset {
        if verbose {
            os_log("\(self.label)ToPlayAsset: size(\(self.size.debugDescription))")
        }
        
        return PlayAsset(url: self.url, like: self.like, size: size)
    }
    
    static func fromPlayAsset(_ asset: PlayAsset) -> Audio {
        Audio(asset.url)
    }
}

// MARK: Size

extension Audio {
    func getFileSizeReadable() -> String {
        FileHelper.getFileSizeReadable(size ?? getFileSize())
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}
