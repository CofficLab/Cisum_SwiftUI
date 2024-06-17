import Foundation
import OSLog

struct MetadataItemCollection: Sendable {
    var name: Notification.Name
    var isUpdated = false
    var items: [MetaWrapper] = []
    
    var count: Int {
        items.count
    }
    
    var first: MetaWrapper? {
        items.first
    }
    
    var itemsForSync: [MetaWrapper] {
        items.filter { $0.isUpdated == false }
    }
    
    var itemsForUpdate: [MetaWrapper] {
        items.filter { $0.isUpdated && $0.isDeleted == false }
    }
    
    var itemsForDelete: [MetaWrapper] {
        items.filter { $0.isDeleted }
    }
}

struct MetaWrapper: Sendable {
    static var label = "📁 MetaWrapper::"
    
    let fileName: String?
    let fileSize: Int?
    let contentType: String?
    let isDirectory: Bool
    let url: URL?
    let isPlaceholder: Bool
    let isDeleted: Bool
    /// 发生了变动
    let isUpdated: Bool
    let downloadProgress: Double
    let uploaded: Bool
    let identifierKey: String? = nil
    
    var isDownloaded: Bool {
        downloadProgress == 100 || isPlaceholder == false
    }
    
    // 如果是占位文件且下载进度大于0且小于100，则认为文件正在下载
    var isDownloading: Bool {
        isPlaceholder && downloadProgress > 0.0 && downloadProgress < 100.0
    }
    
    var label: String { "\(Logger.isMain)\(Self.label)" }

    init(metadataItem: NSMetadataItem, isDeleted: Bool = false, isUpdated: Bool = false, verbose: Bool = false) {
        // MARK: FileName
        
        let fileName: String? = metadataItem.value(forAttribute: NSMetadataItemFSNameKey) as? String
        
        // MARK: PlaceHolder
        
        var isPlaceholder: Bool = false
        if let downloadingStatus = metadataItem.value(forAttribute: NSMetadataUbiquitousItemDownloadingStatusKey) as? String {
            if downloadingStatus == NSMetadataUbiquitousItemDownloadingStatusNotDownloaded {
                // 文件是占位文件
                isPlaceholder = true
            } else if downloadingStatus == NSMetadataUbiquitousItemDownloadingStatusDownloaded || downloadingStatus == NSMetadataUbiquitousItemDownloadingStatusCurrent {
                // 文件已下载或是最新的
                isPlaceholder = false
            } else {
                isPlaceholder = false
            }
        }
        
        // MARK: DownloadProgress
        
        let downloadProgress = metadataItem.value(forAttribute: NSMetadataUbiquitousItemPercentDownloadedKey) as? Double ?? 0.0
        
        self.fileName = fileName
        self.isPlaceholder = isPlaceholder
        self.isDeleted = isDeleted
        self.isUpdated = isUpdated
        self.fileSize = metadataItem.value(forAttribute: NSMetadataItemFSSizeKey) as? Int
        self.contentType = metadataItem.value(forAttribute: NSMetadataItemContentTypeKey) as? String
        self.isDirectory = (self.contentType == "public.folder")
        self.url = metadataItem.value(forAttribute: NSMetadataItemURLKey) as? URL
        self.downloadProgress = downloadProgress
        // 是否已经上传完毕(只有 0 和 100 两个状态)
        self.uploaded = (metadataItem.value(forAttribute: NSMetadataUbiquitousItemPercentUploadedKey) as? Double ?? 0.0) == 100
        
        if verbose {
            os_log("\(Logger.isMain)\(Self.label)Init -> \(fileName ?? "") -> PlaceHolder: \(isPlaceholder) -> \(downloadProgress)")
        }
    }
}
