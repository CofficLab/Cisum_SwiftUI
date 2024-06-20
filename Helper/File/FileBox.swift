import Foundation

protocol FileBox {
    var url: URL { get }
}

// MARK: Meta

extension FileBox {
    var title: String { url.lastPathComponent }
    var ext: String { url.pathExtension }
}

// MARK: FileSize

extension FileBox {
    func getFileSize() -> Int64 {
        FileHelper.getFileSize(url)
    }

    func getFileSizeReadable() -> String {
        FileHelper.getFileSizeReadable(getFileSize())
    }
}

// MARK: iCloud 相关

extension FileBox {
    var isDownloaded: Bool {
        iCloudHelper.isDownloaded(url)
    }
    
    var isDownloading: Bool {
        iCloudHelper.isDownloading(url)
    }
    
    var isNotDownloaded: Bool {
        !isDownloaded
    }
}

// MARK: HASH

extension FileBox {
    func getHash(verbose: Bool = true) -> String {
        FileHelper.getMD5(self.url)
    }
}

// MARK: Exists

extension FileBox {
    // 未解决的问题：ios上文件APP中能看到，但FileManager.default.exits返回false
    func isExists() -> Bool {
        FileManager.default.fileExists(atPath: url.path)
    }

    func isNotExists() -> Bool {
        !isExists()
    }
}
