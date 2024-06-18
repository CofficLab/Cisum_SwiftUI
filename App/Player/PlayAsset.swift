import SwiftUI

struct PlayAsset {
    var url: URL
    let fileManager = FileManager.default
    
    var title: String { url.lastPathComponent }
    var ext: String { url.pathExtension }
    
    // 未解决的问题：ios上文件APP中能看到，但FileManager.default.exits返回false
    func isExists() -> Bool {
        fileManager.fileExists(atPath: url.path)
    }
    
    func isNotExists() -> Bool {
        !isExists()
    }
    
    func isDownloading() -> Bool {
        iCloudHelper.isDownloading(self.url)
    }
    
    func isDownloaded() -> Bool {
        iCloudHelper.isDownloaded(url: self.url)
    }
    
    func isSupported() -> Bool {
        AppConfig.supportedExtensions.contains(ext.lowercased())
    }
}

// MARK: Audio

extension PlayAsset {
    func toAudio() -> Audio {
        Audio(self.url)
    }
}

#Preview {
    AppPreview()
}
