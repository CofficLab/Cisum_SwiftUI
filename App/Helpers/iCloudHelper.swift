import SwiftUI
import OSLog

class iCloudHelper {
    static func iCloudEnabled() -> Bool {
        return FileManager.default.ubiquityIdentityToken != nil
    }
    
    static func getStatus(_ url: URL) -> String {
        getDownloadingStatus(url: url).rawValue
    }
    
    static func getDownloadingStatus(url: URL) -> URLUbiquitousItemDownloadingStatus {
        //os_log("🔧 iCloudHelper::getDownloadingStatus -> \(url.absoluteString)")
        do {
            let values = try url.resourceValues(forKeys:[.ubiquitousItemDownloadingStatusKey])
            let status = values.ubiquitousItemDownloadingStatus
            
            if status == nil {
                return URLUbiquitousItemDownloadingStatus.downloaded
            } else {
                return status!
            }
        } catch {
            fatalError("\(error)")
        }
    }
    
    static func isDownloaded(url: URL)-> Bool {
        return [URLUbiquitousItemDownloadingStatus.current, URLUbiquitousItemDownloadingStatus.downloaded].contains(getDownloadingStatus(url: url))
    }
    
    static func isNotDownloaded(_ url: URL) -> Bool {
        !isDownloaded(url: url)
    }
    
    static func isOnDisk(url: URL) -> Bool {
        return FileManager.default.fileExists(atPath: url.absoluteString)
    }
    
    static func isNotOnDisk(_ url: URL) -> Bool {
        !isOnDisk(url: url)
    }
    
    static func isCloudPath(url: URL) -> Bool {
        if let resourceValues = try? url.resourceValues(forKeys:[.isUbiquitousItemKey]),
           resourceValues.isUbiquitousItem == true {
           return true
        } else {
            return false
        }
    }
    
    static func getiCloudDocumentsUrl() -> URL {
        if AppConfig.fileManager.ubiquityIdentityToken != nil {
                AppConfig.logger.cloudKit.debug("支持 iCloud")
                
            return AppConfig.fileManager.url(forUbiquityContainerIdentifier: AppConfig.container)!.appendingPathComponent("Documents")
            } else {
                AppConfig.logger.cloudKit.debug("不支持 iCloud，使用本地目录")
                
                return AppConfig.documentsDir
            }
        }
}
