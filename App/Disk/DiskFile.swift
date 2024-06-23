import Foundation
import OSLog

struct DiskFile: FileBox, Hashable, Identifiable {
    static var home: DiskFile = DiskFile(url: URL.homeDirectory)
    static var label = "👶 DiskFile::"

    var id: URL { url }
    var url: URL
    var isDownloading: Bool = false
    var isUpdated: Bool = false
    var isDeleted: Bool = false
    var isDownloaded: Bool = true
    var isFolder: Bool = false
    var downloadProgress: Double = 1.0
    var index: Int = 0

    var label: String {
        "\(Logger.isMain)\(Self.label)"
    }
}

extension DiskFile {
    func toAudio() -> Audio {
        Audio(url)
    }

    static func fromURL(_ url: URL) -> Self {
        DiskFile(url: url, isDownloading: false, downloadProgress: 1)
    }

    static func fromMetaWrapper(_ meta: MetaWrapper) -> Self {
        DiskFile(
            url: meta.url!,
            isDownloading: meta.isDownloading,
            isDeleted: meta.isDeleted,
            isFolder: meta.isDirectory,
            downloadProgress: meta.downloadProgress
        )
    }
}

// MARK: Children

extension DiskFile {
    func getChildren() -> [DiskFile]? {
        let fileManager = FileManager.default

        do {
            var files = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: [.nameKey], options: .skipsHiddenFiles)

            files.sort { $0.lastPathComponent < $1.lastPathComponent }

            let children: [DiskFile] = files.map { DiskFile(url: $0) }

            return children.isEmpty ? nil : children
        } catch {
            // Handle error
            return nil
        }
    }
}

// MARK: Next

extension DiskFile {
    func next() -> DiskFile? {
        let next: DiskFile? = nil

        os_log("\(label)Next of \(title)")

        guard let parent = parent, let siblings = parent.getChildren() else {
            os_log("\(label)Next of \(title) -> nil")

            return next
        }

        guard let index = siblings.firstIndex(of: self) else {
            return nil
        }
        
        guard siblings.count > self.index + 1 else {
            os_log("\(label)Next of \(title) -> nil")

            return next
        }

        let nextIndex = index + 1
        if nextIndex < siblings.count {
            return siblings[nextIndex]
        } else {
            return nil // 已经是数组的最后一个元素
        }
    }
}

// MARK: Next

extension DiskFile {
    func prev() -> DiskFile? {
        let prev: DiskFile? = nil

        os_log("\(label)Prev of \(title)")

        guard let parent = parent, let siblings = parent.getChildren() else {
            os_log("\(label)Prev of \(title) -> nil")

            return prev
        }
        
        guard let index = siblings.firstIndex(of: self) else {
            return nil
        }
        
        guard index - 1 >= 0 else {
            os_log("\(label)Prev of \(title) -> nil")

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
}
