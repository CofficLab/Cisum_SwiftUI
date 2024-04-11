import AVKit
import Combine
import Foundation
import MediaPlayer
import OSLog
import SwiftUI

class EventManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
    var n = NotificationCenter.default
    var queue = DispatchQueue(label: "EventQueue")
    
    func emitUpdate(_ items: [MetadataItemWrapper]) {
        NotificationCenter.default.post(
            name: NSNotification.Name(Event.Updated.name),
            object: nil,
            userInfo: [
                "items": items
            ]
        )
    }
    
    func onUpdated(_ callback: @escaping (_ items: [MetadataItemWrapper]) -> Void) {
        n.addObserver(
            forName: NSNotification.Name(Event.Updated.name),
            object: nil,
            queue: .main,
            using: { notification in
                self.queue.async {
                    let data = notification.userInfo as! [String: [MetadataItemWrapper]]
                    let items = data["items"]!
                    callback(items)
                }
            })
    }
    
    enum Event {
        case Updated
        
        var name: String {
            String(describing: self)
        }
    }
}