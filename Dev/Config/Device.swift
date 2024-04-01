import Foundation

enum Device: Equatable {
    case iMac
    case MacBook
    case iPhoneBig
    case iPhoneSmall
    case iPad

    var isMac: Bool {
        self.type == .Mac
    }

    var isiPhone: Bool {
        self.type == .iPhone
    }

    var isiPad: Bool {
        self.type == .iPad
    }

    var type: DeviceType {
        switch self {
        case .iMac:
            return .Mac
        case .MacBook:
            return .Mac
        case .iPad:
            return .iPad
        case .iPhoneBig:
            return .iPhone
        case .iPhoneSmall:
            return .iPhone
        }
    }

    var description: String {
        switch self {
        case .iMac:
            return "iMac"
        case .MacBook:
            return "MacBook"
        case .iPad:
            return "iPad"
        case .iPhoneBig:
            return "iPhoneBig"
        case .iPhoneSmall:
            return "iPhoneSmall"
        }
    }

    var width: CGFloat {
        switch self {
        case .iMac:
            2880
        case .MacBook:
            2880
        case .iPhoneBig:
            1290
        case .iPhoneSmall:
            1242
        case .iPad:
            2048
        }
    }

    var height: CGFloat {
        switch self {
        case .iMac:
            1800
        case .MacBook:
            1800
        case .iPhoneBig:
            2796
        case .iPhoneSmall:
            2208
        case .iPad:
            2732
        }
    }
}
