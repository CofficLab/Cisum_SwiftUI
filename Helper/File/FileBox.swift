import AVKit
import Foundation
import OSLog
import SwiftUI
import MagicKit

#if os(iOS) || os(visionOS)
    import UIKit
    typealias PlatformImage = UIImage
#elseif os(macOS)
    import AppKit
    typealias PlatformImage = NSImage
#endif

protocol FileBox: Identifiable, SuperLog {
    var url: URL { get }
}

extension FileBox {
    static var emoji: String { "🎁" }
}

// MARK: Meta

extension FileBox {
    var title: String { url.deletingPathExtension().lastPathComponent }
    var fileName: String { url.lastPathComponent }
    var ext: String { url.pathExtension }
    var contentType: String {
        do {
            let resourceValues = try url.resourceValues(forKeys: [.typeIdentifierKey])
            return resourceValues.contentType?.identifier ?? ""
        } catch {
            print("Error getting content type: \(error)")
            return ""
        }
    }

    var isImage: Bool {
        ["png", "jpg", "jpeg", "gif", "bmp", "webp"].contains(ext)
    }

    var isJSON: Bool {
        ext == "json"
    }

    var isWMA: Bool {
        ext == "wma"
    }
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

    func getFileSizeReadable(verbose: Bool = false) -> String {
        if verbose {
            os_log("\(self.t)GetFileSizeReadable for \(url.lastPathComponent)")
        }

        return FileHelper.getFileSizeReadable(getFileSize())
    }

    private func getFolderSize(_ url: URL) -> Int64 {
        var totalSize: Int64 = 0

        do {
            let fileManager = FileManager.default
            let contents = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: [.fileSizeKey], options: .skipsHiddenFiles)

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

// MARK: Parent

extension FileBox {
    var parentURL: URL? {
        guard let parentURL = url.deletingLastPathComponent() as URL? else {
            return nil
        }

        return parentURL
    }
}

// MARK: Children

extension FileBox {
    var children: [URL]? {
        getChildren()
    }

    func getChildren() -> [URL]? {
        getChildrenOf(self.url)
    }

    func getChildrenOf(_ url: URL, verbose: Bool = false) -> [URL]? {
        if verbose {
            os_log("\(self.t)GetChildrenOf \(url.lastPathComponent)")
        }

        let fileManager = FileManager.default

        do {
            var files = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: [.nameKey], options: .skipsHiddenFiles)

            files.sort { $0.lastPathComponent < $1.lastPathComponent }

            return files.isEmpty ? nil : files
        } catch {
            return nil
        }
    }
}

// MARK: Next

extension FileBox {
    func next(verbose: Bool = false) -> URL? {
        if verbose {
            os_log("\(t)Next of \(fileName)")
        }

        guard let parent = parentURL, let siblings = getChildrenOf(parent) else {
            os_log("\(t)Next of \(fileName) -> nil")

            return nil
        }

        guard let index = siblings.firstIndex(of: self.url) else {
            return nil
        }

        guard siblings.count > index + 1 else {
            if verbose {
                os_log("\(t)Next of \(fileName) -> nil")
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

extension FileBox {
    func prev() -> URL? {
        let prev: URL? = nil

        os_log("\(t)Prev of \(fileName)")

        guard let parent = parentURL, let siblings = getChildrenOf(parent) else {
            os_log("\(t)Prev of \(fileName) -> nil")

            return prev
        }

        guard let index = siblings.firstIndex(of: self.url) else {
            return nil
        }

        guard index - 1 >= 0 else {
            os_log("\(t)Prev of \(fileName) -> nil")

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
            os_log("\(self.t)IsExists -> \(url.path)")
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
        ["mp4"].contains(self.ext)
    }

    func isAudio() -> Bool {
        [".mp3", ".wav"].contains(self.ext)
    }

    func isNotAudio() -> Bool {
        !isAudio()
    }
}
