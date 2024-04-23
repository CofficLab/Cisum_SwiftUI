import Foundation
import SwiftUI

enum Device: String, Equatable {
    case iMac
    case MacBook
    case iPhone_15
    case iPhoneBig
    case iPhoneSmall
    case iPad_mini

    var size: String {
        "\(Int(width)) x \(Int(height))"
    }

    var isMac: Bool {
        self.category == .MacBook || self.category == .iMac
    }

    var isiPhone: Bool {
        self.category == .iPhone
    }

    var isiPad: Bool {
        self.category == .iPad
    }

    var category: DeviceCategory {
        switch self {
        case .iMac:
            .iMac
        case .MacBook:
            .MacBook
        case .iPad_mini:
            .iPad
        case .iPhoneBig, .iPhone_15, .iPhoneSmall:
            .iPhone
        }
    }

    var description: String {
        self.rawValue
    }

    var width: CGFloat {
        switch self {
        case .iMac:
            4480
        case .MacBook:
            2880
        case .iPhoneBig:
            1290
        case .iPhoneSmall:
            1242
        case .iPad_mini:
            1488
        case .iPhone_15:
            1179
        }
    }

    var height: CGFloat {
        switch self {
        case .iMac:
            2520
        case .MacBook:
            1800
        case .iPhoneBig:
            2796
        case .iPhoneSmall:
            2208
        case .iPad_mini:
            2266
        case .iPhone_15:
            2556
        }
    }
}

#Preview("Layout") {
    LayoutView()
}

#Preview("iPhone 15") {
    LayoutView(device: .iPad_mini)
}

#Preview("iPad") {
    LayoutView(device: .iPad_mini)
}

#Preview("350") {
    LayoutView(width: 350)
}

#Preview("400") {
    LayoutView(width: 400)
}

#Preview("500") {
    LayoutView(width: 500)
}
