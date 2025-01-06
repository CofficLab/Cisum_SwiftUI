import Foundation
import SwiftUI
import OSLog
import AVKit
import MagicKit
import MagicUI

struct DiskFile: Hashable, Identifiable, SuperLog {
    static var home: DiskFile = DiskFile(url: URL.homeDirectory)
    static var emoji = "👶"
    
    var fileManager = FileManager.default
    var id: URL { url }
    var url: URL
    var isDownloading: Bool = false
    var isUpdated: Bool = false
    var isDeleted: Bool = false
    var isDownloaded: Bool = true
    var isFolder: Bool = false
    var downloadProgress: Double = 1.0
    var index: Int = 0
    var contentType: String?
    var size: Int64?
    var isPlaceholder: Bool = false

    static func fromURL(_ url: URL) -> Self {
        DiskFile(url: url, isDownloading: false, downloadProgress: 1)
    }

    static func fromMetaWrapper(_ meta: MetaWrapper, verbose: Bool = false) -> Self {
        if verbose {
            os_log("\(Self.t)FromMetaWrapper -> \(meta.url?.path ?? "-") -> \(meta.downloadProgress)")
        }
        
        return DiskFile(
            url: meta.url!,
            isDownloading: meta.isDownloading,
            isDeleted: meta.isDeleted,
            isDownloaded: meta.isDownloaded, isFolder: meta.isDirectory,
            downloadProgress: meta.downloadProgress,
            size: meta.fileSize,
            isPlaceholder: meta.isPlaceholder
        )
    }

    func onChange(_ callback: @escaping () -> Void) {
        let presenter = FilePresenter(fileURL: self.url)
        
        presenter.onDidChange = {
            os_log("\(self.t)变了 -> \(url.lastPathComponent)")
            
            callback()
        }
    }
    
    var childrenOptional: [DiskFile]? {
        children
    }

    var children: [DiskFile] {
        let c: [URL] = url.getChildren() 
        return c.map({DiskFile(url: $0)})
    }

    func nextDiskFile(verbose: Bool = false) -> DiskFile? {
        if verbose {
            os_log("\(t)Next of \(self.url.title)")
        }

        if let nextURL = self.url.next() {
            return DiskFile(url: nextURL)
        } else {
            return nil
        }
    }

    func prevDiskFile() -> DiskFile? {
        if let prevURL = self.url.getPrevFile() {
            DiskFile(url: prevURL)
        } else {
            nil
        }
    }

    var parent: DiskFile? {
        DiskFile.fromURL(url.getParent())
    }
    
    func toAudio(verbose: Bool = false) -> AudioModel {
        if verbose {
            os_log("\(self.t)ToAudio: size(\(size.debugDescription))")
        }
        
        return AudioModel(url, size: size, isFolder: isFolder)
    }

    func toBook(verbose: Bool = false) -> Book {
        if verbose {
            os_log("\(self.t)ToBook: title(\(self.url.title))")
        }
        
        return Book(url: url)
    }
}
