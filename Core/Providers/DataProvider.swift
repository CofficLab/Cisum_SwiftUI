import CloudKit
import OSLog
import SwiftData
import SwiftUI
import MagicKit

class DataProvider: ObservableObject, SuperLog {
    let label = "💼"
    var db: DB
    var container: ModelContainer

    @Published var disk: any Disk
    @Published var syncing: Bool = false

    var isiCloudDisk: Bool {
        disk is DiskiCloud
    }

    var isNotiCloudDisk: Bool {
        !(disk is DiskiCloud)
    }

    init() async throws {
        self.disk = DiskLocal.make("audios") ?? DiskLocal(root: URL(fileURLWithPath: "/tmp"))
        self.container = Config.getContainer
        self.db = DB(self.container, reason: "DataProvider.Init")

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
        let verbose = false

        if verbose {
            os_log("\(self.t)Checking iCloud status")
        }

        let accountStatus = try await CKContainer.default().accountStatus()
        switch accountStatus {
        case .couldNotDetermine:
            if verbose {
                os_log("iCloud status: could not determine")
            }
        case .available:
            if verbose {
                os_log("\(self.t)iCloud status: available")
            }
        case .restricted:
            if verbose {
                os_log("iCloud status: restricted")
            }
        case .noAccount:
            if verbose {
                os_log("iCloud status: no account")
            }

            throw DataProviderError.NoiCloudAccount
        case .temporarilyUnavailable:
            if verbose {
                os_log("\(self.t)iCloud status: temporarily unavailable")
            }

            throw DataProviderError.iCloudAccountTemporarilyUnavailable
        @unknown default:
            os_log(.error, "iCloud status: unknown")
        }
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
                os_log("\(self.t)将文件从 \(from.name) 移动到 \(to.name)")
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
                        os_log("\(self.t)移动 \(sourceURL.lastPathComponent)")
                    }
                    await from.moveFile(at: sourceURL, to: destnationURL)
                }
            } catch {
                os_log("Error: \(error)")
            }

            if verbose {
                os_log("\(self.t)将文件从 \(from.name) 移动到 \(to.name) 完成 🎉🎉🎉")
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
            return "登录 iCloud 后使用"
        }
    }
}

#Preview {
    AppPreview()
        .frame(height: 800)
}
