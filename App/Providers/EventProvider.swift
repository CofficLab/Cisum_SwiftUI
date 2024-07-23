import AVKit
import Combine
import Foundation
import MediaPlayer
import OSLog
import SwiftUI

class EventProvider: NSObject, ObservableObject, AVAudioPlayerDelegate, SuperLog {
    static var label = "🍋 EventManager::"
    
    var n = NotificationCenter.default
    var queue = DispatchQueue(label: "EventQueue")
    var label: String { "\(Logger.isMain)\(Self.label)" }
    
    func emitUpdate(_ items: DiskFileGroup) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: Notification.Name.AudiosUpdatedNotification,
                object: nil,
                userInfo: [
                    "items": items
                ]
            )
        }
    }
    
    func emitAudioUpdate(_ audio: Audio) {
            NotificationCenter.default.post(
                name: Notification.Name.AudioUpdatedNotification,
                object: nil,
                userInfo: [
                    "audio": audio
                ]
            )
        }
    
    func emitSyncing(_ total: Int, current: Int) {
        NotificationCenter.default.post(
            name: NSNotification.Name(Event.Syncing.name),
            object: nil,
            userInfo: [
                "total": total,
                "current": current
            ]
        )
    }
    
    func emitDelete(_ items: [MetaWrapper]) {
        NotificationCenter.default.post(
            name: NSNotification.Name(Event.Delete.name),
            object: nil,
            userInfo: [
                "items": items
            ]
        )
    }
    
    func onDelete(_ callback: @escaping (_ items: [MetaWrapper]) -> Void) {
        n.addObserver(
            forName: NSNotification.Name(Event.Delete.name),
            object: nil,
            queue: .main,
            using: { notification in
                self.queue.async {
                    let data = notification.userInfo as! [String: [MetaWrapper]]
                    let items = data["items"]!
                    callback(items)
                }
            })
    }
    
    func onSyncing(_ callback: @escaping (_ total: Int, _ current: Int) -> Void) {
        n.addObserver(
            forName: NSNotification.Name(Event.Syncing.name),
            object: nil,
            queue: .main,
            using: { notification in
                self.queue.async {
                    let data = notification.userInfo as! [String: Int]
                    let total = data["total"]!
                    let current = data["current"]!
                    callback(total, current)
                }
            })
    }
    
    func removeListener(_ observer: Any) {
        os_log("\(self.label)RemoveListener")
        n.removeObserver(observer)
    }
    
    enum Event {
        case Updated
        case Delete
        case Syncing
        
        var name: String {
            String(describing: self)
        }
    }
}

// MARK: 扩展Notification

extension Notification.Name {
    static let AudiosUpdatedNotification = Notification.Name("AudiosUpdatedNotification")
    static let AudioUpdatedNotification = Notification.Name("AudioUpdatedNotification")
}
