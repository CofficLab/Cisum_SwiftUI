import OSLog
import SwiftUI

class iCloudHelper {
    static func iCloudEnabled() -> Bool {
        return FileManager.default.ubiquityIdentityToken != nil
    }

    static func getStatus(_ url: URL) -> String {
        getDownloadingStatus(url: url).rawValue
    }

    static func getDownloadingStatus(url: URL) -> URLUbiquitousItemDownloadingStatus {
        // os_log("\(Logger.isMain)🔧 iCloudHelper::getDownloadingStatus -> \(url.absoluteString)")
        do {
            let values = try url.resourceValues(forKeys: [.ubiquitousItemDownloadingStatusKey])
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

    static func isDownloaded(url: URL) -> Bool {
        return [
            URLUbiquitousItemDownloadingStatus.current, URLUbiquitousItemDownloadingStatus.downloaded,
        ].contains(getDownloadingStatus(url: url))
    }

    static func isDownloading(_ url: URL) -> Bool {
        // os_log("\(Logger.isMain)🔧 iCloudHelper::getDownloadingStatus -> \(url.absoluteString)")
        var isDownloading = false
        do {
            let values = try url.resourceValues(forKeys: [.ubiquitousItemIsDownloadingKey])
            for item in values.allValues {
                if item.key == .ubiquitousItemIsDownloadingKey && item.value as! Bool {
                    isDownloading = true
                }
            }
        } catch {
            fatalError("\(error)")
        }

        return isDownloading
    }

    static func isNotDownloaded(_ url: URL) -> Bool {
        !isDownloaded(url: url)
    }

    static func fileExists(url: URL) -> Bool {
        return FileManager.default.fileExists(atPath: url.absoluteString)
    }

    static func isNotExists(_ url: URL) -> Bool {
        !fileExists(url: url)
    }

    static func isCloudPath(url: URL) -> Bool {
        if let resourceValues = try? url.resourceValues(forKeys: [.isUbiquitousItemKey]),
           resourceValues.isUbiquitousItem == true
        {
            return true
        } else {
            return false
        }
    }

    static func getiCloudDocumentsUrl() -> URL {
        if AppConfig.fileManager.ubiquityIdentityToken != nil {
            AppConfig.logger.cloudKit.debug("支持 iCloud")

            return AppConfig.fileManager.url(forUbiquityContainerIdentifier: AppConfig.containerIdentifier)!
                .appendingPathComponent("Documents")
        } else {
            AppConfig.logger.cloudKit.debug("不支持 iCloud，使用本地目录")

            return AppConfig.cloudDocumentsDir
        }
    }

    static func checkiCloudStorage1() {
        // 获取当前iCloud容量
        let fileManager = FileManager.default
        if let currentiCloudToken = fileManager.ubiquityIdentityToken {
            print("iCloud Accessible \(currentiCloudToken)")

            // 使用URLForResourceValues方法获取iCloud的容量信息
            if let iCloudContainerURL = fileManager.url(forUbiquityContainerIdentifier: nil) {
                do {
                    let values = try iCloudContainerURL.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey, .volumeTotalCapacityKey])

                    if let availableCapacity = values.volumeAvailableCapacityForImportantUsage,
                       let totalCapacity = values.volumeTotalCapacity
                    {
                        print("Total iCloud capacity: \(totalCapacity) bytes")
                        print("Available iCloud capacity: \(availableCapacity) bytes")

                        // 根据需要处理空间不足的情况
                        if availableCapacity <= 0 {
                            print("iCloud storage is full")
                            // 这里可以添加代码来处理存储空间已满的情况
                        }
                    }
                } catch {
                    print("Error retrieving iCloud storage information: \(error)")
                }
            }
        } else {
            print("No iCloud Access")
            // 这里可以添加代码来处理无法访问iCloud的情况
        }
    }

    static func checkiCloudStorage2() {
        let fileManager = FileManager.default

        if let url = fileManager.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") {
            do {
                let attributes = try fileManager.attributesOfFileSystem(forPath: url.path)

                let space = attributes[FileAttributeKey.systemSize] as? NSNumber
                let freeSpace = attributes[FileAttributeKey.systemFreeSize] as? NSNumber
                if let space = space, let freeSpace = freeSpace {
                    let spaceGB = space.int64Value / 1024 / 1024 / 1024
                    let freeSpaceGB = freeSpace.int64Value / 1024 / 1024 / 1024

                    print("iCloud total space: \(spaceGB) GB")
                    print("iCloud free space: \(freeSpaceGB) GB")
                }

            } catch {
                print(error)
            }
        }
    }
}
