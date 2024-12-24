import AVFoundation
import CryptoKit
import Foundation
import OSLog
import SwiftData
import SwiftUI
import MagicKit

/* 存储音频数据，尤其是将计算出来的属性存储下来 */

@Model
class AudioModel: FileBox {
    @Transient
    var coverFolder: URL = AudioConfig.getCoverFolderUrl()
    static var verbose = false

    @Transient let fileManager = FileManager.default
    @Transient var db: AudioDB?

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
    var hasCover: Bool?
    var fileHash: String?
    var isFolder: Bool = false

    var verbose: Bool { Self.verbose }
    var dislike: Bool { !like }
    var children: [AudioModel]? {
        if url == .applicationDirectory {
            return nil
        }

        return [AudioModel(.applicationDirectory)]
    }

    init(_ url: URL,
         size: Int64? = nil,
         title: String? = nil,
         identifierKey: String? = nil,
         contentType: String? = nil,
         isFolder: Bool = false
    ) {
        if Self.verbose {
            os_log("\(Self.i) -> \(url.lastPathComponent)")
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

    func setDB(_ db: AudioDB?) {
        self.db = db
    }
}

extension AudioModel: SuperLog {
    static var emoji: String { "🪖" }
}

extension AudioModel: SuperCover {
    
}

// MARK: Order

extension AudioModel {
    static func makeRandomOrder() -> Int {
        Int.random(in: 101 ... 500000000)
    }

    func randomOrder() {
        order = Self.makeRandomOrder()
    }
}

// MARK: ID

extension AudioModel: Identifiable {
    var id: PersistentIdentifier { persistentModelID }
}

// MARK: Transform

extension AudioModel {
    func toPlayAsset(verbose: Bool = false) -> PlayAsset {
        if verbose {
            os_log("\(self.t)ToPlayAsset: size(\(self.size.debugDescription))")
        }

        return PlayAsset(url: self.url, like: self.like, size: size).setSource(self)
    }

    static func fromPlayAsset(_ asset: PlayAsset) -> AudioModel {
        AudioModel(asset.url)
    }
}

// MARK: Size

extension AudioModel {
    func getFileSizeReadable() -> String {
        FileHelper.getFileSizeReadable(size ?? getFileSize())
    }
}

extension AudioModel: PlaySource {
    func getCoverImage() async throws -> Image? {
        try await self.getCoverImage()
    }
    
    func delete() async throws {
        guard let db = db else {
            throw AudioModelError.dbNotFound
        }

        try await db.delete(self, verbose: true)
    }

    func download() async throws {
        guard let db = db else {
            throw AudioModelError.dbNotFound
        }

        try await db.download(self, verbose: true)
    }
    
    func toggleLike() async throws {
        guard let db = db else {
            throw AudioModelError.dbNotFound
        }

        try await db.toggleLike(self.url)
    }
}

enum AudioModelError: Error, LocalizedError {
    case deleteFailed
    case dbNotFound

    var errorDescription: String? {
        switch self {
        case .deleteFailed:
            return "Delete failed"
        case .dbNotFound:
            return "AudioModel: DB not found"
        }
    }
}

// MARK: Descriptor

extension AudioModel {
    static var descriptorOrderAsc: FetchDescriptor<AudioModel> {
        var descriptor = FetchDescriptor<AudioModel>()
        descriptor.sortBy.append(.init(\.order, order: .forward))
        return descriptor
    }

    static var descriptorOrderDesc: FetchDescriptor<AudioModel> {
        var descriptor = FetchDescriptor<AudioModel>()
        descriptor.sortBy.append(.init(\.order, order: .reverse))
        return descriptor
    }

    static var descriptorFirst: FetchDescriptor<AudioModel> {
        var descriptor = FetchDescriptor<AudioModel>()
        descriptor.sortBy.append(.init(\.order, order: .forward))
        descriptor.fetchLimit = 1
        return descriptor
    }

    static func descriptorPrev(order: Int) -> FetchDescriptor<AudioModel> {
        var descriptor = FetchDescriptor<AudioModel>()
        descriptor.sortBy.append(.init(\.order, order: .reverse))
        descriptor.fetchLimit = 1
        descriptor.predicate = #Predicate {
            $0.order < order
        }
        return descriptor
    }

    static func descriptorNext(order: Int) -> FetchDescriptor<AudioModel> {
        var descriptor = FetchDescriptor<AudioModel>()
        descriptor.sortBy.append(.init(\.order, order: .forward))
        descriptor.fetchLimit = 1
        descriptor.predicate = #Predicate {
            $0.order > order
        }
        return descriptor
    }

    static var descriptorAll = FetchDescriptor(predicate: #Predicate<AudioModel> { _ in
        true
    }, sortBy: [
        SortDescriptor(\.order, order: .forward),
    ])

    static var descriptorNotFolder = FetchDescriptor(predicate: predicateNotFolder, sortBy: [
        SortDescriptor(\.order, order: .forward),
    ])

    static var predicateNotFolder = #Predicate<AudioModel> { audio in
        audio.isFolder == false
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}
