import Foundation
import OSLog

struct MetadataItemCollection: Sendable {
    var isUpdated = false
    var items: [MetadataItemWrapper] = []
}

struct MetadataItemWrapper: Sendable {
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
    let identifierKey: String?

    init(metadataItem: NSMetadataItem, isDeleted: Bool = false, isUpdated: Bool = false, verbose: Bool = true) {
        if verbose {
//            var message = ""
//            metadataItem.attributes.forEach({
//                message += ("  \($0) -> \(String(describing: metadataItem.value(forAttribute: $0))) \n")
//            })
//            
//            os_log("\(message)")
//            
//            message = "=========\n"
//            [
//                NSMetadataItemDisplayNameKey,
//                NSMetadataItemAlbumKey,
//                NSMetadataItemTitleKey,
//                NSMetadataItemIdentifierKey,
//                NSMetadataItemGenreKey,
//                NSMetadataUbiquitousItemIsDownloadingKey,
//                NSMetadataItemCodecsKey,
//                NSMetadataItemKeywordsKey,
//                NSMetadataItemCFBundleIdentifierKey,
//                NSMetadataItemVersionKey,
//                NSMetadataItemKeySignatureKey,
//                NSMetadataItemFSSizeKey,
//                NSMetadataItemDurationSecondsKey,
//                NSMetadataItemContentTypeKey,
//                NSMetadataUbiquitousItemContainerDisplayNameKey,
//                NSMetadataUbiquitousItemURLInLocalContainerKey,
//                NSMetadataItemFSCreationDateKey,
//                NSMetadataItemCreatorKey,
//                NSMetadataItemContentCreationDateKey,
//                NSMetadataItemIsUbiquitousKey,
//                "BRMetadataItemFileObjectIdentifierKey",
//                NSMetadataItemFSContentChangeDateKey,
//            ].forEach({
//                let v = metadataItem.value(forAttribute: $0)
//                
//                if let s = v as? String {
//                    message += ("  \($0) -> String: \(s) \n")
//                } else if let i = v as? Int {
//                    message += ("  \($0) -> Int: \(i) \n")
//                } else if let d = v as? Date {
//                    message += ("  \($0) -> Date: \(d) \n")
//                } else if let o = v as? ObjectIdentifier {
//                    message += ("  \($0) -> \(o.debugDescription) \n")
//                } else {
//                    message += ("  \($0) -> \(String(describing: metadataItem.value(forAttribute: $0))) -> \(type(of: metadataItem.value(forAttribute: $0)))) \n")
//                }
//            })
//            
//            os_log("\(message)=========")
        }
        
        self.isDeleted = isDeleted
        self.isUpdated = isUpdated
        self.fileName = metadataItem.value(forAttribute: NSMetadataItemFSNameKey) as? String
        self.fileSize = metadataItem.value(forAttribute: NSMetadataItemFSSizeKey) as? Int
        self.contentType = metadataItem.value(forAttribute: NSMetadataItemContentTypeKey) as? String
        self.identifierKey = metadataItem.value(forAttribute: NSMetadataItemAuthorsKey) as? String
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
        
//        let t = self.contentType
//        let title = self.fileName
//        os_log("MetadataItemWrapper: \n ContentType -> \(t ?? "") \n Title -> \(title ?? "")")
    }
}
