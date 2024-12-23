import CloudKit
import MagicKit
import OSLog
import SwiftData
import SwiftUI

class DataProvider: ObservableObject, SuperLog {
    static let emoji = "💼"
    let emoji = "💼"

    @Published var syncing: Bool = false

    init(verbose: Bool) async throws {
        if verbose {
            os_log("\(Self.i)")
        }

        if Config.iCloudEnabled {
            if verbose {
                os_log("\(Self.t)设置中启用了 iCloud")
            }

            try await self.checkAndUpdateiCloudStatus(verbose: verbose)
        }
    }

    // MARK: Copy

    func deleteCopyTask(_ task: CopyTask) {
//        Task {
//            await db.deleteCopyTask(task.id)
//        }
    }

    func copy(_ urls: [URL]) {
//        Task {
//            await self.db.addCopyTasks(urls)
//        }
    }

    func checkAndUpdateiCloudStatus(verbose: Bool) async throws {
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
        let disk = DiskiCloud.make("audios", verbose: true, reason: "DataProvider.enableiCloud")

        guard disk != nil else {
            throw DataProviderError.NoiCloudDisk
        }

        migrate()
    }

    func disableiCloud() throws {
        os_log("\(self.t)Disable iCloud")
        let disk = DiskLocal.make("audios", verbose: true, reason: "DataProvider.disableiCloud")

        guard disk != nil else {
            throw DataProviderError.NoLocalDisk
        }

        migrate()
    }

    func migrate() {
        guard let localMountedURL = DiskLocal.getMountedURL(verbose: true) else {
            return
        }

        guard let cloudMoutedURL = DiskiCloud.getMountedURL(verbose: true) else {
            return
        }

        let localDisk = DiskLocal(root: localMountedURL)
        let cloudDisk = DiskiCloud(root: cloudMoutedURL, delegate: nil)

        if Config.iCloudEnabled {
            moveAudios(localDisk, cloudDisk)
        } else {
            moveAudios(cloudDisk, localDisk)
        }
    }

    func moveAudios(_ from: any SuperDisk, _ to: any SuperDisk, verbose: Bool = true) {
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
        nil
//        db.firstAudio()?.toPlayAsset()
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
    case NoiCloudDisk
    case NoLocalDisk
    case iCloudAccountTemporarilyUnavailable
    case NoiCloudAccount

    var errorDescription: String? {
        switch self {
        case .NoiCloudDisk:
            return "没有 iCloud 磁盘"
        case .NoLocalDisk:
            return "没有本地磁盘"
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
