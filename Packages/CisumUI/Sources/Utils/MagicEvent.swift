import Foundation

public struct MagicEvent {
    public static let onLoadComplete = "onLoadComplete"
    public static let onJavaScriptError = "onJavaScriptError"
    public static let onCustomMessage = "onCustomMessage"

    static var notification: NotificationCenter {
        NotificationCenter.default
    }

    static var nc: NotificationCenter { NotificationCenter.default }

    static func emit(_ name: Notification.Name, object: Any? = nil, userInfo: [AnyHashable: Any]? = nil) {
        DispatchQueue.main.async {
            self.nc.post(name: name, object: object, userInfo: userInfo)
        }
    }

    static func emit(name: Notification.Name, object: Any? = nil, userInfo: [AnyHashable: Any]? = nil) {
        self.emit(name, object: object, userInfo: userInfo)
    }
}
