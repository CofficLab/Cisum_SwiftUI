import MagicKit
import OSLog
import SwiftUI

class iCloudHelper: SuperLog, SuperThread {
    static var label = "☁️ iCloudHelper::"

    static func iCloudEnabled() -> Bool {
        return FileManager.default.ubiquityIdentityToken != nil
    }

    // MARK: 下载状态

    static func getStatus(_ url: URL) -> String {
        getDownloadingStatus(url: url).rawValue
    }

    static func getDownloadingStatus(url: URL) -> URLUbiquitousItemDownloadingStatus {
        var s: URLUbiquitousItemDownloadingStatus = .notDownloaded
        printRunTime("GetDownloadingStatus -> \(url.lastPathComponent)", tolerance: 1, {
            do {
                let values = try url.resourceValues(forKeys: [.ubiquitousItemDownloadingStatusKey])
                let status = values.ubiquitousItemDownloadingStatus

                if status == nil {
                    s = URLUbiquitousItemDownloadingStatus.downloaded
                } else {
                    s = status!
                }
            } catch {
                fatalError("\(error)")
            }
        })
        return s
    }

    static func isPlaceholder(_ url: URL) -> Bool {
        do {
            return try url.resourceValues(forKeys: [.isUbiquitousItemKey]).isUbiquitousItem ?? false
        } catch {
            os_log("Error getting isUbiquitousItem for file: %@, Error: %@", log: .default, type: .error, url.path, error.localizedDescription)
            return false
        }
    }

    static func isDownloaded(_ url: URL) -> Bool {
        let verbose = true

        // 文件不存在且占位符不存在，则认为文件不存在
        if !FileManager.default.fileExists(atPath: url.path) && !isPlaceholder(url) {
            if verbose {
                os_log("文件不存在: %@", log: .default, type: .info, url.path)
            }
            return false
        }

        // 文件不存在且占位符存在，则认为未下载
        if !FileManager.default.fileExists(atPath: url.path) && isPlaceholder(url) {
            if verbose {
                os_log("占位符存在: %@", log: .default, type: .info, url.path)
            }
            return false
        }

        do {
            let values = try url.resourceValues(forKeys: [.ubiquitousItemDownloadingStatusKey, .fileSizeKey])

            // 检查 ubiquitousItemDownloadingStatusKey
            if let status = values.ubiquitousItemDownloadingStatus {
                switch status {
                case .current, .downloaded:
                    return true
                case .notDownloaded:
                    return false
                default:
                    os_log("Unknown download status for file: %@", log: .default, type: .error, url.path)
                    // 对于未知状态，如果文件存在且有大小，则认为已下载
                    if FileManager.default.fileExists(atPath: url.path),
                       let fileSize = values.fileSize, fileSize > 0 {
                        os_log("文件已存在且有大小: %@, 认为已下载", log: .default, type: .info, url.path)
                        return true
                    }
                    return false
                }
            } else {
                // 如果状态为 nil，但文件存在且有大小，则认为已下载
                if FileManager.default.fileExists(atPath: url.path),
                   let fileSize = values.fileSize, fileSize > 0 {
                    os_log("文件已存在且有大小: %@, 认为已下载", log: .default, type: .info, url.path)
                    return true
                }
                return false
            }
        } catch {
            os_log("Error getting download status for file: %@, Error: %@", log: .default, type: .error, url.path, error.localizedDescription)

            // 获取父文件夹的路径
            let parentURL = url.deletingLastPathComponent()

            // 获取父文件夹的子文件
            do {
                let contents = try FileManager.default.contentsOfDirectory(at: parentURL, includingPropertiesForKeys: nil, options: [])

                // 输出子文件的路径
                for childURL in contents {
                    os_log("子文件路径: %@", log: .default, type: .info, childURL.path)
                }
            } catch {
                os_log("获取父文件夹内容时出错: %@", log: .default, type: .error, error.localizedDescription)
            }

            // If there's an error, but file exists, consider it downloaded
            if FileManager.default.fileExists(atPath: url.path) {
                os_log("文件已存在且有大小: %@, 认为已下载", log: .default, type: .info, url.path)
                return true
            }
            return false
        }
    }

    static func isDownloading(_ url: URL) -> Bool {
        let verbose = false

        if verbose {
            os_log("Checking download status for file: %@", log: .default, type: .info, url.path)
        }

        do {
            let values = try url.resourceValues(forKeys: [.ubiquitousItemDownloadingStatusKey, .ubiquitousItemIsDownloadingKey])

            // 首先检查 ubiquitousItemIsDownloadingKey
            if let isDownloading = values.ubiquitousItemIsDownloading, isDownloading {
                os_log("\(Self.label)File is currently downloading: \(url.lastPathComponent)")
                return true
            }

            // 然后检查 ubiquitousItemDownloadingStatusKey
            if let status = values.ubiquitousItemDownloadingStatus {
                switch status {
                case .current:
                    return false // 文件已经是最新的，不在下载中
                case .notDownloaded:
                    return false // 文件未下载，但也不在下载中
                case .downloaded:
                    return false // 文件已下载完成，不在下载中
                default:
                    os_log("Unknown download status: %@", log: .default, type: .error, status.rawValue)
                    return false
                }
            }

            os_log("No download status available for file: %@", log: .default, type: .info, url.path)
            return false
        } catch {
            os_log("Error checking download status for file: %@, Error: %@", log: .default, type: .error, url.path, error.localizedDescription)
            return false
        }
    }

    static func isNotDownloaded(_ url: URL) -> Bool {
        !isDownloaded(url)
    }

    // TODO: 下载进度

    // MARK: Exists

    static func fileExists(url: URL) -> Bool {
        return FileManager.default.fileExists(atPath: url.absoluteString)
    }

    static func isNotExists(_ url: URL) -> Bool {
        !fileExists(url: url)
    }

    static func isCloudPath(url: URL) -> Bool {
        if let resourceValues = try? url.resourceValues(forKeys: [.isUbiquitousItemKey]),
           resourceValues.isUbiquitousItem == true {
            return true
        } else {
            return false
        }
    }

    static func watchDownloading(_ url: URL) {
        // 创建一个后台队列
        let backgroundQueue = DispatchQueue(label: "com.example.backgroundQueue", qos: .background)

        // iCloud 文件的路径
        let iCloudFilePath = url.path

        // 在后台队列中执行获取 iCloud 文件下载进度的操作
        backgroundQueue.async {
            let query = NSMetadataQuery()
            query.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
            query.predicate = NSPredicate(format: "%K == %@", NSMetadataItemPathKey, iCloudFilePath)

            NotificationCenter.default.addObserver(
                forName: .NSMetadataQueryDidUpdate,
                object: query,
                queue: nil
            ) { notification in
                if let updatedItems = notification.userInfo?[NSMetadataQueryUpdateChangedItemsKey] as? [NSMetadataItem] {
                    for item in updatedItems {
                        if let percentDownloaded = item.value(forAttribute: NSMetadataUbiquitousItemPercentDownloadedKey) as? Double {
                            print("Download progress: \(percentDownloaded * 100)%")
                        }
                    }
                }
            }

            query.start()

            // Run the run loop to keep the query running
            RunLoop.current.run()
        }
    }
}

// MARK: 容量相关

extension iCloudHelper {
    enum iCloudError: Error {
        case NoAccess
        case CanNotGetCapacity
        case CanNotGetContainer
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
                       let totalCapacity = values.volumeTotalCapacity {
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

    // MARK: 获取剩余容量

    static func getAvailableStorage() throws -> Int64 {
        // 获取当前iCloud容量
        let fileManager = FileManager.default

        guard fileManager.ubiquityIdentityToken != nil else {
            throw iCloudError.NoAccess
        }

        guard let iCloudContainerURL = fileManager.url(forUbiquityContainerIdentifier: nil) else {
            throw iCloudError.CanNotGetContainer
        }

        // 使用URLForResourceValues方法获取iCloud的容量信息
        do {
            let values = try iCloudContainerURL.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey, .volumeTotalCapacityKey])

            if let availableCapacity = values.volumeAvailableCapacityForImportantUsage {
                return availableCapacity
            } else {
                throw iCloudError.CanNotGetCapacity
            }
        } catch {
            print("Error retrieving iCloud storage information: \(error)")
            throw error
        }
    }

    // MARK: 获取总容量

    static func getTotalStorage() throws -> Int {
        // 获取当前iCloud容量
        let fileManager = FileManager.default

        guard fileManager.ubiquityIdentityToken != nil else {
            throw iCloudError.NoAccess
        }

        guard let iCloudContainerURL = fileManager.url(forUbiquityContainerIdentifier: nil) else {
            throw iCloudError.CanNotGetContainer
        }

        // 使用URLForResourceValues方法获取iCloud的容量信息
        do {
            let values = try iCloudContainerURL.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey, .volumeTotalCapacityKey])

            if let totalCapacity = values.volumeTotalCapacity {
                return totalCapacity
            } else {
                throw iCloudError.CanNotGetCapacity
            }
        } catch {
            print("Error retrieving iCloud storage information: \(error)")
            throw error
        }
    }

    // MARK: 获取总容量Readable

    static func getTotalStorageReadable() -> String {
        do {
            return try formatBytes(getTotalStorage())
        } catch let e {
            print(e)
            return ""
        }
    }

    // MARK: 获取剩余容量Readable

    static func getAvailableStorageReadable() -> String {
        do {
            return try formatBytes(Int(getAvailableStorage()))
        } catch let e {
            print(e)
            return ""
        }
    }

    static func formatBytes(_ bytes: Int) -> String {
        let byteUnits = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"]
        var index = 0
        var bytes = Double(bytes)

        while bytes >= 1024 {
            bytes /= 1024
            index += 1
        }

        return String(format: "%.2f %@", bytes, byteUnits[index])
    }

    /// 执行并输出耗时
    static func printRunTime(_ title: String, tolerance: Double = 1, verbose: Bool = false, _ code: () -> Void) {
        if verbose {
            os_log("\(Logger.isMain)\(Self.label)\(title)")
        }

        let startTime = DispatchTime.now()

        code()

        // 计算码执行时间
        let nanoTime = DispatchTime.now().uptimeNanoseconds - startTime.uptimeNanoseconds
        let timeInterval = Double(nanoTime) / 1000000000

        if verbose && timeInterval > tolerance {
            os_log("\(Logger.isMain)\(DB.label)\(title) cost \(timeInterval) 秒 🐢🐢🐢")
        }
    }
}
