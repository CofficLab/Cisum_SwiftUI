
import Foundation

protocol SuperEvent {
}

// MARK: Player

extension SuperEvent {
    func emitPlayerEventCurrent(_ asset: PlayAsset?) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .PlayerEventCurrent, object: asset)
        }
    }
    
    func emitPlayerEventNext(_ asset: PlayAsset?) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .PlayerEventNext, object: asset)
        }
    }
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
