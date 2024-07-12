import Foundation
import SwiftUI
import OSLog
import AVKit

struct DiskFile: FileBox, Hashable, Identifiable, Playable {
    static var home: DiskFile = DiskFile(url: URL.homeDirectory)
    static var label = "👶 DiskFile::"
    
    var fileManager = FileManager.default
    var id: URL { url }
    var url: URL
    var isDownloading: Bool = false
    var isUpdated: Bool = false
    var isDeleted: Bool = false
    var isDownloaded: Bool = true
    var isFolder: Bool = false
    var downloadProgress: Double = 1.0
    var index: Int = 0
    var contentType: String?
    var size: Int64?

    var label: String {
        "\(Logger.isMain)\(Self.label)"
    }
}

extension DiskFile {
    static func fromURL(_ url: URL) -> Self {
        DiskFile(url: url, isDownloading: false, downloadProgress: 1)
    }

    static func fromMetaWrapper(_ meta: MetaWrapper, verbose: Bool = false) -> Self {
        if verbose {
            os_log("\(Self.label)FromMetaWrapper -> \(meta.url?.path ?? "-") -> \(meta.downloadProgress)")
        }
        
        return DiskFile(
            url: meta.url!,
            isDownloading: meta.isDownloading,
            isDeleted: meta.isDeleted,
            isFolder: meta.isDirectory,
            downloadProgress: meta.downloadProgress,
            size: meta.fileSize
        )
    }
}

// MARK: OnChage

extension DiskFile {
    func onChange(_ callback: @escaping () -> Void) {
        let presenter = FilePresenter(fileURL: self.url)
        
        presenter.onDidChange = {
            os_log("\(self.label)变了 -> \(url.lastPathComponent)")
            
            callback()
        }
    }
}

// MARK: Children

extension DiskFile {
    var children: [DiskFile]? {
        if let c = getChildren() {
            return c.map({DiskFile(url: $0)})
        } else {
            return nil
        }
    }
}

// MARK: Next

extension DiskFile {
    func nextDiskFile(verbose: Bool = false) -> DiskFile? {
        if verbose {
            os_log("\(label)Next of \(fileName)")
        }

        if let nextURL = self.next() {
            return DiskFile(url: nextURL)
        } else {
            return nil
        }
    }
}

// MARK: Prev

extension DiskFile {
    func prevDiskFile() -> DiskFile? {
        if let prevURL = self.prev() {
            DiskFile(url: prevURL)
        } else {
            nil
        }
    }
}

// MARK: Parent

extension DiskFile {
    var parent: DiskFile? {
        guard let parentURL = url.deletingLastPathComponent() as URL? else {
            return nil
        }

        return DiskFile.fromURL(parentURL)
    }
}

// MARK: Tramsform

extension DiskFile {
    func toPlayAsset() -> PlayAsset {
        PlayAsset(url: url)
    }
    
    func toAudio(verbose: Bool = false) -> Audio {
        if verbose {
            os_log("\(self.label)ToAudio: size(\(size.debugDescription))")
        }
        
        return Audio(url, size: size, isFolder: isFolder)
    }

    func toBook(verbose: Bool = false) -> Book {
        if verbose {
            os_log("\(self.label)ToBook: title(\(title))")
        }
        
        return Book(url: url, isFolder: isFolder())
    }
}
