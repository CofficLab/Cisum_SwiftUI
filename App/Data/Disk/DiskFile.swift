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
        getChildren()
    }
    
    func getChildren() -> [DiskFile]? {
        let fileManager = FileManager.default

        do {
            var files = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: [.nameKey], options: .skipsHiddenFiles)

            files.sort { $0.lastPathComponent < $1.lastPathComponent }

            let children: [DiskFile] = files.map { DiskFile(url: $0) }

            return children.isEmpty ? nil : children
        } catch {
            return nil
        }
    }
}

// MARK: Next

extension DiskFile {
    func next(verbose: Bool = false) -> DiskFile? {
        if verbose {
            os_log("\(label)Next of \(fileName)")
        }

        guard let parent = parent, let siblings = parent.getChildren() else {
            os_log("\(label)Next of \(fileName) -> nil")

            return nil
        }

        guard let index = siblings.firstIndex(of: self) else {
            return nil
        }
        
        guard siblings.count > self.index + 1 else {
            if verbose {
                os_log("\(label)Next of \(fileName) -> nil")
            }

            return nil
        }

        let nextIndex = index + 1
        if nextIndex < siblings.count {
            return siblings[nextIndex]
        } else {
            return nil // 已经是数组的最后一个元素
        }
    }
}

// MARK: Prev

extension DiskFile {
    func prev() -> DiskFile? {
        let prev: DiskFile? = nil

        os_log("\(label)Prev of \(fileName)")

        guard let parent = parent, let siblings = parent.getChildren() else {
            os_log("\(label)Prev of \(fileName) -> nil")

            return prev
        }
        
        guard let index = siblings.firstIndex(of: self) else {
            return nil
        }
        
        guard index - 1 >= 0 else {
            os_log("\(label)Prev of \(fileName) -> nil")

            return prev
        }

        let prevIndex = index - 1
        if prevIndex < siblings.count {
            return siblings[prevIndex]
        } else {
            return nil
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
