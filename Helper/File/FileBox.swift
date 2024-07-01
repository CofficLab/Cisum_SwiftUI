import Foundation
import OSLog
import SwiftUI

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
        if self.isNotFolder() {
            FileHelper.getFileSize(url)
        } else {
            getFolderSize(self.url)
        }
        
    }

    func getFileSizeReadable() -> String {
        FileHelper.getFileSizeReadable(getFileSize())
    }
    
    private func getFolderSize(_ url: URL) -> Int64 {
        var totalSize: Int64 = 0
        
        do {
            let fileManager = FileManager.default
            let contents = try  fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: [.fileSizeKey], options: .skipsHiddenFiles)
            
            for itemURL in contents {
                if itemURL.hasDirectoryPath {
                    totalSize += getFolderSize(itemURL)
                } else {
                    totalSize += FileHelper.getFileSize(itemURL)
                }
            }
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }
        
        return totalSize
    }
}

// MARK: iCloud 相关

extension FileBox {
    var isDownloaded: Bool {
        isFolder() || iCloudHelper.isDownloaded(url)
    }
    
    var isDownloading: Bool {
        iCloudHelper.isDownloading(url)
    }
    
    var isNotDownloaded: Bool {
        !isDownloaded
    }
    
    var isiCloud: Bool {
        iCloudHelper.isCloudPath(url: url)
    }
    
    var isNotiCloud: Bool {
        !isiCloud
    }
    
    var isLocal: Bool {
        isNotiCloud
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

// MARK: Icon

extension FileBox {
    var icon: String {
        isFolder() ? "folder" : "doc.text"
    }
    
    var image: Image {
        Image(systemName: icon)
    }
}

// MARK: Sub

extension FileBox {
    func inDir(_ dir: URL) -> Bool {
        FileHelper.isURLInDirectory(self.url, dir)
    }
    
    func has(_ url: URL) -> Bool {
        FileHelper.isURLInDirectory(url, self.url)
    }
}

// MARK: Format

extension FileBox {
    func isVideo() -> Bool {
        [".mp4"].contains(self.ext)
    }
    
    func isAudio() -> Bool {
        [".mp3", ".wav"].contains(self.ext)
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}
