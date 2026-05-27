import CloudKit
import Foundation
import OSLog
import SwiftData

/// For syncing the local database with the iCloud database
public final actor SmartSync: SuperThread, SuperLog {
    let nc = NotificationCenter.default
    var verbose: Bool = false
    let cloudState: CloudState
    var syncEngine: CKSyncEngine?
    var cloudDB: CKDatabase
    let delegate: SuperSyncDelegate

    var engine: CKSyncEngine {
        if syncEngine == nil {
            initEngine()
        }

        return syncEngine!
    }

    public init(delegate: SuperSyncDelegate, db: CKDatabase, stateURL: URL, verbose: Bool) throws {
        if verbose {
            os_log("\(Self.i)")
        }
        self.cloudState = try CloudState(reason: "SyncAgent", url: stateURL)
        self.delegate = delegate
        self.verbose = verbose
        self.cloudDB = db

        Task {
            await initEngine()
        }
    }

    private func initEngine() {
        if verbose {
            os_log("\(self.i)SyncEngine")
        }
        var config = CKSyncEngine.Configuration(
            database: cloudDB,
            stateSerialization: self.cloudState.getState(),
            delegate: self
        )
        config.automaticallySync = true

        syncEngine = CKSyncEngine(config)
    }
}

// MARK: CKSyncEngineDelegate

extension SmartSync: CKSyncEngineDelegate {
    public func handleEvent(_ event: CKSyncEngine.Event, syncEngine: CKSyncEngine) async {
        let verbose = true

        switch event {
        case let .stateUpdate(event):
            do {
                try self.cloudState.updateState(event.stateSerialization)
            } catch let error as CloudState.Error {
                os_log(.error, "\(self.t)Failed to save cloud state: \(error)")
                await self.delegate.onCloudStateSaveFailed(error: error)
            } catch {
                os_log(.error, "\(self.t)Failed to save cloud state with unexpected error: \(error)")
                // Handle generic error case if needed
            }
            break

        case let .accountChange(event):
            await self.handleAccountChange(event)
            break

        case let .fetchedDatabaseChanges(event):
            self.handleFetchedDatabaseChanges(event)
            break

        case let .fetchedRecordZoneChanges(event):
            await self.handleFetchedRecordZoneChanges(event)
            break

        case let .sentRecordZoneChanges(event):
            await self.handleSentRecordZoneChanges(event)
            break

        case .sentDatabaseChanges:
            break
        case .willSendChanges:
            await self.handleWillSendChanges()
            break

        case .didSendChanges:
            await self.handleDidSendChanges()
            break

        case .willFetchChanges:
            await self.handleWillFetchChanges()
            break

        case .didFetchChanges:
            await self.handleDidFetchChanges()
            break

        case .willFetchRecordZoneChanges:
            break

        case .didFetchRecordZoneChanges:
            break

        @unknown default:
            if verbose {
                os_log("\(self.t)Received unknown event: \(event)")
            }
        }
    }

    // MARK: NextRecordZoneChangeBatch

    public func nextRecordZoneChangeBatch(
        _ context: CKSyncEngine.SendChangesContext,
        syncEngine: CKSyncEngine
    ) async -> CKSyncEngine.RecordZoneChangeBatch? {
        let verbose = false
        let verbose2 = false

        let scope = context.options.scope
        let changes = syncEngine.state.pendingRecordZoneChanges.filter { scope.contains($0) }

        if verbose && changes.isNotEmpty {
            os_log("\(self.t)Send Changes(\(changes.count)) ⏫⏫⏫")
        }

        let batch = await CKSyncEngine.RecordZoneChangeBatch(pendingChanges: changes) { recordID in
            // 获取将要被上传的记录
            if let record = try? await self.delegate.onGetModel(recordID: recordID) {
                if verbose && changes.prefix(5).contains(.saveRecord(recordID)) {
                    os_log("  🚀 Sending -> \(record.recordType)(\(recordID.recordName))")
                }

                if verbose2 && changes.prefix(5).contains(.saveRecord(recordID)) {
                    for key in record.allKeys() {
                        os_log("   ♦️ \(key): \(String(describing: record[key]).max(200))")
                    }
                }

                return record
            }

            // 本地找不到相关记录，不需要同步了
            syncEngine.state.remove(pendingRecordZoneChanges: [.saveRecord(recordID)])

            return nil
        }

        return batch
    }

    // MARK: Upload
    
    public func uploadOne(_ model: any SuperCloudModel, verbose: Bool) throws {
        if verbose {
            os_log("\(self.t)✅ UploadOne: \(model.debugTitle)")
        }

        try self.upload([model])
    }

    public func upload(_ models: [any SuperCloudModel]) throws {
        if models.isEmpty {
            return
        }

        engine.state.add(pendingRecordZoneChanges: models.map {
            .saveRecord($0.privateRecordID)
        })
    }

    public func delete(_ id: CKRecord.ID, reason: String) throws {
        if verbose {
            os_log("""
            \(self.t)🗑️ iCloud Delete(\(id.recordName))
            - Zone: \(id.zoneID.zoneName)
            - Name: \(id.recordName)
            - Reason: \(reason)
            """)
        }

        try delete([id])
    }

    /// delete records from iCloud
    func delete(_ ids: [CKRecord.ID]) throws {
        engine.state.add(pendingRecordZoneChanges: ids.map {
            .deleteRecord($0)
        })
    }

    func reset() {
        let verbose = true

        if verbose {
            os_log("\(self.t)Reset SyncEngine")
            os_log("  ➡️ PendingRecordZoneChanges(\(self.engine.state.pendingRecordZoneChanges.count))")
        }

        // If we're deleting everything, we need to clear out all our sync engine state too.
        // In order to do that, let's re-initialize our sync engine.
        initEngine()

        if verbose {
            os_log("\(self.t)Reset SyncEngine Done")
            os_log("  ➡️ PendingRecordZoneChanges(\(self.engine.state.pendingRecordZoneChanges.count))")
        }
    }

    public func deleteZone(zone: CKRecordZone) async throws {
        let verbose = true

        if verbose {
            os_log("\(self.t)🗑️ Delete Zone -> \(zone.zoneID.zoneName)")
            os_log("  ➡️ PendingRecordZoneChanges(\(self.engine.state.pendingRecordZoneChanges.count))")
        }

        // 移除所有待处理的记录区域更改
        engine.state.remove(pendingRecordZoneChanges: engine.state.pendingRecordZoneChanges)

        // 移除所有待处理的数据库更改
        engine.state.remove(pendingDatabaseChanges: engine.state.pendingDatabaseChanges)

        // 添加删除区域的操作
        engine.state.add(pendingDatabaseChanges: [.deleteZone(zone.zoneID)])
        
        try await engine.sendChanges()
    }
}

// MARK: Event Handler

extension SmartSync {
    func handleDidFetchChanges() async {
        let verbose = false
        if verbose {
            os_log("\(self.t)DidFetchChanges 🎉🎉🎉")
        }
        await self.delegate.onDidFetchChanges()
    }

    func handleWillFetchChanges() async {
        let verbose = false
        if verbose {
            os_log("\(self.t)WillFetchChanges ⏬⏬⏬")
        }
        await self.delegate.onWillFetchChanges()
    }

    // MARK: Fetched Record Zone Changes

    func handleFetchedRecordZoneChanges(_ event: CKSyncEngine.Event.FetchedRecordZoneChanges) async {
        let verbose = false

        if verbose {
            os_log("\(self.t)FetchedRecordZoneChanges")
            os_log("  🈴 Merge(\(event.modifications.count))")

            if event.deletions.isNotEmpty {
                os_log("  🗑️ Delete(\(event.deletions.count))")
            }
        }

        for modification in event.modifications {
            if verbose {
                os_log("  🚀 Merge -> \(modification.record.recordType)(\(modification.record.recordID.recordName))")
            }
            await self.delegate.onMerge(record: modification.record)
        }

        for deletion in event.deletions {
            await self.delegate.onDelete(deletion: deletion)
        }
    }

    // MARK: Account Change

    func handleAccountChange(_ event: CKSyncEngine.Event.AccountChange) async {
        // Handling account changes can be tricky.
        //
        // If the user signed out of their account, we want to delete all local data.
        // However, what if there's some data that hasn't been uploaded yet?
        // Should we keep that data? Prompt the user to keep the data? Or just delete it?
        //
        // Also, what if the user signs in to a new account, and there's already some data locally?
        // Should we upload it to their account? Or should we delete it?
        //
        // Finally, what if the user signed in, but they were signed into a previous account before?
        //
        // Since we're in a sample app, we're going to take a relatively simple approach.

        let shouldDeleteLocalData: Bool
        let shouldReUploadLocalData: Bool

        switch event.changeType {
        case .signIn:
            if verbose {
                os_log("\(self.t)🍋 iCloud 登录事件")
            }
            shouldDeleteLocalData = false
            shouldReUploadLocalData = true

        case .switchAccounts:
            if verbose {
                os_log("\(self.t)🚉 iCloud 切换账号")
            }
            shouldDeleteLocalData = true
            shouldReUploadLocalData = false

        case .signOut:
            if verbose {
                os_log("\(self.t)iCloud 登出")
            }
            shouldDeleteLocalData = true
            shouldReUploadLocalData = false

        @unknown default:
            os_log("\(self.t)未知 iCloud 账户变动事件: \(event)")
            shouldDeleteLocalData = false
            shouldReUploadLocalData = false
        }

        if shouldDeleteLocalData {
            if verbose {
                os_log("\(self.t)清空本地数据")
            }
        }

        if shouldReUploadLocalData {
            if verbose {
                os_log("\(self.t)⏫ ShouldReUploadLocalData")
            }

            let items: [any SuperCloudModel] = await self.delegate.onGetAll()
            let zones = Set(items.map { $0.zone })

            syncEngine!.state.add(pendingDatabaseChanges: zones.map {
                .saveZone($0)
            })

            syncEngine!.state.add(pendingRecordZoneChanges: items.map {
                .saveRecord($0.privateRecordID)
            })
        }
    }

    // MARK: Sent Record Zone Changes

    func handleSentRecordZoneChanges(_ event: CKSyncEngine.Event.SentRecordZoneChanges) async {
        let verbose = false

        // If we failed to save a record, we might want to retry depending on the error code.
        var newPendingRecordZoneChanges = [CKSyncEngine.PendingRecordZoneChange]()
        var newPendingDatabaseChanges = [CKSyncEngine.PendingDatabaseChange]()

        let savedRecords = event.savedRecords
        let failedRecordSaves = event.failedRecordSaves

        if verbose {
            os_log("\(self.t)SentRecordZoneChanges")
            os_log("  ➡️ SavedRecords(\(savedRecords.count))")

            if failedRecordSaves.isNotEmpty {
                os_log("  ➡️ FailedRecordSaves(\(failedRecordSaves.count))")
            }
        }

        // Update the last known server record for each of the saved records.
        for savedRecord in event.savedRecords {
            await self.delegate.onSaved(record: savedRecord)
        }

        for failedRecordSave in event.failedRecordSaves {
            let failedRecord = failedRecordSave.record
            let recordName = failedRecord.recordID.recordName
            let recordType = failedRecord.recordType
            var shouldClearServerRecord = false

            switch failedRecordSave.error.code {
                
            // MARK: ServerRecordChanged

            /*
                当有多个设备使用更新同一块数据的时候，本地数据及其容易与服务器数据冲突。
                比如设备 A 和 设备B 都缓存有相同的 RecordA-1，
                    A 在某个时候修改成了 RecordA-2 并同步到 iCloud。
                    之后 B 也要修改 RecordA-1，B 将其改为 RecordA-3，这时 B 同步到 iCloud 时就会报错。
             
                解决方法
                    从服务器 fetch 最新的 Record，merge，并保存
             */
            case .serverRecordChanged:
                // Let's merge the record from the server into our own local copy.
                // The `mergeFromServerRecord` function takes care of the conflict resolution.
                guard let serverRecord = failedRecordSave.error.serverRecord else {
                    os_log(.error, "  ❌ No server record for conflict \(failedRecordSave.error)")
                    continue
                }
                
                os_log(.error, "⚠️ HandleSentRecordZoneChanges 保存失败，尝试 Merge：serverRecordChanged ➡️ Record: \(recordType)(\(recordName))")
                await self.delegate.onMerge(record: serverRecord)

                newPendingRecordZoneChanges.append(.saveRecord(failedRecord.recordID))
            case .zoneNotFound:
                os_log(.error, "  ⚠️ 保存失败：zoneNotFound ➡️ Record: \(recordType)(\(recordName))")
                // Looks like we tried to save a record in a zone that doesn't exist.
                // Let's save that zone and retry saving the record.
                // Also clear the last known server record if we have one, it's no longer valid.
                let zone = CKRecordZone(zoneID: failedRecord.recordID.zoneID)
                newPendingDatabaseChanges.append(.saveZone(zone))
                newPendingRecordZoneChanges.append(.saveRecord(failedRecord.recordID))
                shouldClearServerRecord = true

            case .unknownItem:
                os_log(.error, "\(self.t)保存失败：unknownItem")
                // We tried to save a record with a locally-cached server record, but that record no longer exists on the server.
                // This might mean that another device deleted the record, but we still have the data for that record locally.
                // We have the choice of either deleting the local data or re-uploading the local data.
                // For this sample app, let's re-upload the local data.
                newPendingRecordZoneChanges.append(.saveRecord(failedRecord.recordID))
                shouldClearServerRecord = true

            case .networkFailure, .networkUnavailable, .zoneBusy, .serviceUnavailable, .notAuthenticated, .operationCancelled:
                // There are several errors that the sync engine will automatically retry, let's just log and move on.
                os_log(.error, "☁️ Retryable error saving \(failedRecord.recordID): \(failedRecordSave.error)")

            default:
                // We got an error, but we don't know what it is or how to handle it.
                // If you have any sort of telemetry system, you should consider tracking this scenario so you can understand which errors you see in the wild.
                os_log(.error, "Unknown error saving record \(failedRecord.recordID): \(failedRecordSave.error)")
                //                if let idea = find(id: failedRecord.toIdea().uuid) {
                //                    idea.getAddress({ address in
                //                        self.logInfo("iCloud 保存失败: \(failedRecordSave.error.localizedDescription)", hero: address)
                //
                //                        if idea.iCloudRetryTimes <= 6 {
                //                            DispatchQueue.global().asyncAfter(deadline: .now() + .random(in: 0 ... 100), execute: {
                //                                self.logInfo("iCloud 重试保存", hero: address)
                //                                idea.update(iCloudRetryTimes: idea.iCloudRetryTimes + 1, completion: { error in
                //                                    Task {
                //                                        do {
                //                                            try await self.saveToiCloud([idea])
                //                                        } catch let error {
                //                                            self.logInfo("\(error.localizedDescription)")
                //                                        }
                //                                    }
                //                                })
                //                            })
                //                        } else {
                //                            self.logInfo("iCloud 保存已重试多次，仍然失败", hero: address)
                //                        }
                //                    })
                //                } else {
                //                    logInfo("iCloud 保存失败的记录在本地未找到，忽略")
                //                }
            }

            if shouldClearServerRecord {
                await self.delegate.onClearLastKnownRecord(failedRecord)
            }
        }

        engine.state.add(pendingDatabaseChanges: newPendingDatabaseChanges)
        engine.state.add(pendingRecordZoneChanges: newPendingRecordZoneChanges)
    }

    // MARK: Fetched Database Changes

    func handleFetchedDatabaseChanges(_ event: CKSyncEngine.Event.FetchedDatabaseChanges) {
        let verbose = true

        for deletion in event.deletions {
            os_log(.error, "Received deletion for zone: \(deletion.zoneID.zoneName)")
        }
    }

    func handleWillSendChanges() async {
        let verbose = false

        if verbose {
            os_log("\(self.t)WillSendChanges 🛫🛫🛫")
        }

        await self.delegate.onWillSendChanges()
    }

    func handleDidSendChanges() async {
        let verbose = false

        if verbose {
            os_log("\(self.t)DidSendChanges 🎉🎉🎉")
        }

        await self.delegate.onDidSendChanges()
    }
}
