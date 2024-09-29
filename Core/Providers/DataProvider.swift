import CloudKit
import OSLog
import SwiftData
import SwiftUI

class DataProvider: ObservableObject, SuperLog {
    static var label = "💼 DataManager::"

    @Published var disk: any Disk
    @Published var syncing: Bool = false

    let emoji = "💼"
    var db: DB = DB(Config.getContainer, reason: "dataManager")

    // Move these computed properties to be calculated based on the disk type
    var isiCloudDisk: Bool {
        disk is DiskiCloud
    }

    var isNotiCloudDisk: Bool {
        !(disk is DiskiCloud)
    }

    init() async throws {
        // Initialize disk with a default value
        self.disk = DiskLocal.make("audios") ?? DiskLocal(root: URL(fileURLWithPath: "/tmp"))

        if Config.iCloudEnabled {
            try await self.checkAndUpdateiCloudStatus()

            guard let iCloudDisk = DiskiCloud.make("audios") else {
                throw DataProviderError.NoDisk
            }

            self.disk = iCloudDisk
        }
    }

    // MARK: Copy

    func deleteCopyTask(_ task: CopyTask) {
        Task {
            await db.deleteCopyTask(task.id)
        }
    }

    func copy(_ urls: [URL]) {
        Task {
            await self.db.addCopyTasks(urls)
        }
    }

    func checkAndUpdateiCloudStatus() async throws {
        os_log("\(self.t)Checking iCloud status")

        let accountStatus = try await CKContainer.default().accountStatus()
        switch accountStatus {
        case .couldNotDetermine:
            os_log("iCloud status: could not determine")
        case .available:
            os_log("iCloud status: available")
        case .restricted:
            os_log("iCloud status: restricted")
        case .noAccount:
            os_log("iCloud status: no account")

            throw DataProviderError.NoiCloudAccount
        case .temporarilyUnavailable:
            os_log("\(self.t)iCloud status: temporarily unavailable")

            throw DataProviderError.iCloudAccountTemporarilyUnavailable
        @unknown default:
            os_log("iCloud status: unknown")
        }
    }
}

// MARK: Download

extension DataProvider {
    func downloadNextBatch(_ url: URL, count: Int = 6, reason: String, verbose: Bool = false) {
//        if verbose {
//            os_log("\(self.t)DownloadNextBatch(\(self.appScene.title))")
//        }

//        if appScene == .Music {
//            Task {
//                var currentIndex = 0
//                var currentURL: URL = url
//
//                while currentIndex < count {
//                    disk.download(currentURL, reason: "downloadNext 🐛 \(reason)")
//
//                    currentIndex = currentIndex + 1
//
//                    if let next = await db.nextOf(currentURL) {
//                        currentURL = next.url
//                    } else {
//                        break
//                    }
//                }
//            }
//        } else {
//            var currentIndex = 0
//            var currentURL: URL = url
//
//            while currentIndex < count {
//                disk.download(currentURL, reason: "downloadNext 🐛 \(reason)")
//
//                currentIndex = currentIndex + 1
//
//                if let next = disk.next(currentURL) {
//                    currentURL = next.url
//                } else {
//                    break
//                }
//            }
//        }
    }
}

// MARK: Migrate

extension DataProvider {
    func enableiCloud() throws {
        os_log("\(self.t)Enable iCloud")
        let disk = DiskiCloud.make("audios")

        guard disk != nil else {
            throw DataProviderError.NoDisk
        }

        migrate()
    }

    func disableiCloud() throws {
        os_log("\(self.t)Disable iCloud")
        let disk = DiskLocal.make("audios")

        guard disk != nil else {
            throw DataProviderError.NoDisk
        }

        migrate()
    }

    func migrate() {
        guard let localMountedURL = DiskLocal.getMountedURL() else {
            return
        }

        guard let cloudMoutedURL = DiskiCloud.getMountedURL() else {
            return
        }

        let localDisk = DiskLocal(root: localMountedURL)
        let cloudDisk = DiskiCloud(root: cloudMoutedURL)

        if Config.iCloudEnabled {
            moveAudios(localDisk, cloudDisk)
        } else {
            moveAudios(cloudDisk, localDisk)
        }
    }

    func moveAudios(_ from: any Disk, _ to: any Disk, verbose: Bool = true) {
        Task.detached(priority: .low) {
            if verbose {
                os_log("\(Self.label)将文件从 \(from.name) 移动到 \(to.name)")
            }

            let fileManager = FileManager.default
            do {
                let files = try fileManager.contentsOfDirectory(atPath: from.root.path).filter({
                    !$0.hasSuffix(".DS_Store")
                })

                for file in files {
                    let sourceURL = URL(fileURLWithPath: from.root.path).appendingPathComponent(file)
                    let destnationURL = to.makeURL(file)

                    if verbose {
                        os_log("\(Self.label)移动 \(sourceURL.lastPathComponent)")
                    }
                    await from.moveFile(at: sourceURL, to: destnationURL)
                }
            } catch {
                os_log("Error: \(error)")
            }

            if verbose {
                os_log("\(Self.label)将文件从 \(from.name) 移动到 \(to.name) 完成 🎉🎉🎉")
            }
        }
    }
}

// MARK: FirstPlayAsset

extension DataProvider {
    func first() -> PlayAsset? {
        db.firstAudio()?.toPlayAsset()
//            disk.getRoot().children?.first?.toPlayAsset()
    }
}

// MARK: Book

extension DataProvider {
    func findBookState(_ book: Book, verbose: Bool = false) -> BookState? {
        if verbose {
            os_log("\(self.t)FindState for \(book.title)")
        }

        let db = DBSynced(Config.getSyncedContainer)

        if let state = db.findOrInsertBookState(book.url) {
            return state
        } else {
            if verbose {
                os_log("\(self.t)\(book.title) 无上次播放")
            }

            return nil
        }
    }

    func updateBookState(_ bookURL: URL, _ current: URL, verbose: Bool = true) {
        if verbose {
            os_log("\(self.t)FindState for \(bookURL.lastPathComponent)")
        }

        Task {
            let db = DBSynced(Config.getSyncedContainer)
            await db.updateBookCurrent(bookURL, currentURL: current)
        }
    }
}

// MARK: Error

enum DataProviderError: Error, LocalizedError, Equatable {
    case NoDisk
    case iCloudAccountTemporarilyUnavailable
    case NoiCloudAccount

    var errorDescription: String? {
        switch self {
        case .NoDisk:
            return "没有磁盘"
        case .iCloudAccountTemporarilyUnavailable:
            return "iCloud 账户暂时不可用"
        case .NoiCloudAccount:
            return "没有 iCloud 账户"
        }

    }
}

#Preview {
    AppPreview()
        .frame(height: 800)
}
