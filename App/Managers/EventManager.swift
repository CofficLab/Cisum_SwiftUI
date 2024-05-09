import AVKit
import Combine
import Foundation
import MediaPlayer
import OSLog
import SwiftUI

class EventManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
    var n = NotificationCenter.default
    var queue = DispatchQueue(label: "EventQueue")
    
    func emitUpdate(_ items: [MetaWrapper]) {
        NotificationCenter.default.post(
            name: NSNotification.Name(Event.Updated.name),
            object: nil,
            userInfo: [
                "items": items
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
    
    func emitAudioUpdate(_ audio: Audio) {
        NotificationCenter.default.post(
            name: NSNotification.Name(Event.AudioUpdated.name),
            object: nil,
            userInfo: [
                "audio": audio
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
    
    func onUpdated(_ callback: @escaping (_ items: [MetaWrapper]) -> Void) {
        n.addObserver(
            forName: NSNotification.Name(Event.Updated.name),
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
    
    func onAudioUpdate(_ callback: @escaping (_ audio: Audio) -> Void) {
        n.addObserver(
            forName: NSNotification.Name(Event.AudioUpdated.name),
            object: nil,
            queue: .main,
            using: { notification in
                self.queue.async {
                    let data = notification.userInfo as! [String: Audio]
                    let audio = data["audio"]!
                    callback(audio)
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
        n.removeObserver(observer)
    }
    
    enum Event {
        case Updated
        case AudioUpdated
        case Delete
        case Syncing
        
        var name: String {
            String(describing: self)
        }
    }
}
