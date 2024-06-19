import Foundation

struct DiskFile {
    var url: URL
    var isDownloading: Bool
    var isUpdated: Bool = false
    var isDeleted: Bool = false
    var isDownloaded: Bool = true
    var isFolder: Bool = false
    var downloadProgress: Double
    var fileName: String
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
