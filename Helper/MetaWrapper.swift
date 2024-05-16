import Foundation
import OSLog

struct MetadataItemCollection: Sendable {
    var isUpdated = false
    var items: [MetaWrapper] = []
}

struct MetaWrapper: Sendable {
    let fileName: String?
    let fileSize: Int?
    let contentType: String?
    let isDirectory: Bool
    let url: URL?
    let isPlaceholder: Bool
    let isDownloading: Bool
    let isDeleted: Bool
    /// 发生了变动
    let isUpdated: Bool
    let downloadProgress: Double
    let uploaded: Bool
    let identifierKey: String? = nil
    
    var isDownloaded: Bool {
        downloadProgress == 100
    }

    init(metadataItem: NSMetadataItem, isDeleted: Bool = false, isUpdated: Bool = false, verbose: Bool = true) {
        self.isDeleted = isDeleted
        self.isUpdated = isUpdated
        self.fileName = metadataItem.value(forAttribute: NSMetadataItemFSNameKey) as? String
        self.fileSize = metadataItem.value(forAttribute: NSMetadataItemFSSizeKey) as? Int
        self.contentType = metadataItem.value(forAttribute: NSMetadataItemContentTypeKey) as? String
        self.isDirectory = (self.contentType == "public.folder")
        self.url = metadataItem.value(forAttribute: NSMetadataItemURLKey) as? URL// 获取下载进度
        self.downloadProgress = metadataItem.value(forAttribute: NSMetadataUbiquitousItemPercentDownloadedKey) as? Double ?? 0.0
        // 是否已经上传完毕(只有 0 和 100 两个状态)
        self.uploaded = (metadataItem.value(forAttribute: NSMetadataUbiquitousItemPercentUploadedKey) as? Double ?? 0.0) == 100

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
        } else {
            // 默认值，假设文件不是占位文件
            isPlaceholder = false
        }

        // 如果是占位文件且下载进度大于0且小于100，则认为文件正在下载
        isDownloading = isPlaceholder && downloadProgress > 0.0 && downloadProgress < 100.0
    }
}
