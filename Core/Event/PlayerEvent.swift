import Foundation

extension Notification.Name {
    static let PlayerEvent = Notification.Name("PlayerEvent")
    static let PlayerEventCurrent = Notification.Name("PlayerEventCurrent")
    static let PlayerEventNext = Notification.Name("PlayerEventNext")
    static let PlayerEventPrevious = Notification.Name("PlayerEventPrevious")
    static let PlayerEventPlay = Notification.Name("PlayerEventPlay")
    static let PlayerEventPause = Notification.Name("PlayerEventPause")
    static let PlayerEventStop = Notification.Name("PlayerEventStop")
    static let PlayerEventSeek = Notification.Name("PlayerEventSeek")
    static let PlayerEventSeekTo = Notification.Name("PlayerEventSeekTo")
    static let PlayerEventSeekToTime = Notification.Name("PlayerEventSeekToTime")
}
