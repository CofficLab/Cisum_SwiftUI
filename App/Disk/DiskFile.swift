import Foundation
import OSLog

struct DiskFile: FileBox,Hashable, Identifiable {
    static var home: DiskFile = DiskFile(url: URL.homeDirectory)
    
    var id: URL {self.url}
    var url: URL
    var isDownloading: Bool = false
    var isUpdated: Bool = false
    var isDeleted: Bool = false
    var isDownloaded: Bool = true
    var isFolder: Bool = false
    var downloadProgress: Double = 1.0
    var index: Int = 0
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
            
            var children: [DiskFile] = files.map { DiskFile(url: $0) }
            
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
        guard let parent = self.parent, let siblings = parent.getChildren(), siblings.count > self.index + 1 else {
            return nil
        }
        
        return siblings[self.index + 1]
    }
}

// MARK: Parent

extension DiskFile {
    var parent: DiskFile? {
        guard let parentURL = self.url.deletingLastPathComponent() as URL? else {
            return nil
        }
        
        return DiskFile.fromURL(parentURL)
    }
}

// MARK: Tramsform

extension DiskFile {
    func toPlayAsset() -> PlayAsset {
        PlayAsset(url: self.url)
    }
}
