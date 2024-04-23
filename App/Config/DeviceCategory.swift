import Foundation

enum DeviceCategory: String, Equatable {
    case iMac
    case MacBook
    case iPhone
    case iPad

    var description: String {
        switch self {
        case .iMac:
            return "iMac"
        case .MacBook:
            return "MacBook"
        case .iPad:
            return "iPad"
        case .iPhone:
            return "iPhone"
        }
    }
}
