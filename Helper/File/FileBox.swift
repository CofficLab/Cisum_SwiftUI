import Foundation
import OSLog

protocol FileBox: Identifiable {
    var url: URL { get }
}

extension FileBox {
    var label: String { "🎁 FileBox::" }
}

// MARK: Meta

extension FileBox {
    var title: String { url.deletingPathExtension().lastPathComponent }
    var fileName: String { url.lastPathComponent }
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
    func isExists(verbose: Bool = false) -> Bool {
        // iOS模拟器，如果是iCloud云盘地址且未下载，FileManager.default.fileExists会返回false
        
        if verbose {
            os_log("\(self.label)IsExists -> \(url.path)")
        }
        
        if iCloudHelper.isCloudPath(url: url) {
            return true
        }
        
        return FileManager.default.fileExists(atPath: url.path)
    }

    func isNotExists() -> Bool {
        !isExists()
    }
}

// MARK: isFolder

extension FileBox {
    func isFolder() -> Bool {
        FileHelper.isDirectory(at: self.url)
    }
    
    func isDirectory() -> Bool {
        isFolder()
    }
    
    func isNotFolder() -> Bool {
        !self.isFolder()
    }
}
