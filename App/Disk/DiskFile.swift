import Foundation

struct DiskFile {
    var url: URL
    var isDownloading: Bool
    var isUpdated: Bool = false
    var isDeleted: Bool = false
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
}
