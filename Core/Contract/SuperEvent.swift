
import Foundation

protocol SuperEvent {
}

// MARK: Audio

extension SuperEvent {
    func emitAudioUpdate(_ audio: Audio) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .AudioUpdatedNotification, object: audio)
        }
    }

    func emitAudiosUpdated(_ audios: [Audio]) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .AudiosUpdatedNotification, object: audios)
        }
    }
}

// MARK: MetaWrapper

extension SuperEvent {
    func emitMetaWrapperDeleted(_ metaWrapper: MetaWrapper) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .MetaWrapperDeletedNotification, object: metaWrapper)
        }
    }

    func emitMetaWrappersDeleted(_ metaWrappers: [MetaWrapper]) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .MetaWrappersDeletedNotification, object: metaWrappers)
        }
    }
}

// MARK: Sync

extension SuperEvent {
    func emitSyncing(total: Int, current: Int) {
        NotificationCenter.default.post(
            name: .SyncingNotification,
            object: nil,
            userInfo: [
                "total": total,
                "current": current,
            ]
        )
    }
}
