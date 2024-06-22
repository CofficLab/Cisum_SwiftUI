import Foundation

struct DiskFile: FileBox {
    var url: URL
    var isDownloading: Bool = false
    var isUpdated: Bool = false
    var isDeleted: Bool = false
    var isDownloaded: Bool = true
    var isFolder: Bool = false
    var downloadProgress: Double = 1.0
    var fileName: String = ""
    var children: [DiskFile]? = nil
    var index: Int = 0
}

extension DiskFile {
    func toAudio() -> Audio {
        Audio(url)
    }
    
    static func fromURL(_ url: URL) -> Self {
        DiskFile(url: url, isDownloading: false, downloadProgress: 1, fileName: url.lastPathComponent)
    }
    
    static func fromMetaWrapper(_ meta: MetaWrapper) -> Self {
        DiskFile(
            url: meta.url!,
            isDownloading: meta.isDownloading,
            isDeleted: meta.isDeleted,
            isFolder: meta.isDirectory,
            downloadProgress: meta.downloadProgress,
            fileName: meta.fileName!
        )
    }
}

// MARK: Children

extension DiskFile {
    func getChildren() -> [DiskFile]? {
        let fileManager = FileManager.default
        
        do {
            let contents = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: [.nameKey, .isDirectoryKey], options: .skipsHiddenFiles)
            var subdirectories = contents.filter { $0.hasDirectoryPath }
            var files = contents.filter { !$0.hasDirectoryPath }
            
            // Sort subdirectories and files by name
            subdirectories.sort { $0.lastPathComponent < $1.lastPathComponent }
            files.sort { $0.lastPathComponent < $1.lastPathComponent }
            
            var children: [DiskFile] = []
            
            for file in files {
                let fileTree = DiskFile(url: file)
                children.append(fileTree)
            }
            
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
        guard let parent = self.parent, let siblings = parent.children, siblings.count > self.index + 1 else {
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
