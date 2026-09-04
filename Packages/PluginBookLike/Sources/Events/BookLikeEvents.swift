import Foundation

public extension Notification.Name {
    /// 书籍喜欢状态变化通知
    static let BookLikeStatusChanged = Notification.Name("BookLikeStatusChanged")
}

public extension NotificationCenter {
    static func postBookLikeStatusChanged(url: URL, liked: Bool) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: .BookLikeStatusChanged,
                object: nil,
                userInfo: [
                    "url": url,
                    "liked": liked
                ]
            )
        }
    }
}
