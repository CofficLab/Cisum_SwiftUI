import Foundation
import SwiftUI

/// A type that represents different Apple devices with their screen specifications
///
/// `MagicDevice` provides screen dimensions and device categorization for common Apple devices.
/// Use this enum to handle device-specific layouts and dimensions in your SwiftUI views.
///
/// Example:
/// ```swift
/// let device = MagicDevice.iPhone_15
/// print(device.size) // "1179 x 2556"
/// print(device.category) // .iPhone
/// ```
public enum MagicDevice: String, Equatable, CaseIterable {
    case iMac
    case MacBook
    case iPhone_15
    case iPhone_SE
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
        case .iPhoneBig, .iPhone_15, .iPhoneSmall, .iPhone_SE:
            .iPhone
        }
    }

    public var description: String {
        self.rawValue
    }

    public var width: CGFloat {
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
        case .iPhone_SE:
            750
        }
    }

    public var height: CGFloat {
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
        case .iPhone_SE:
            1334
        }
    }
}

/// Categories of Apple devices
///
/// This enum groups devices into major categories for easier device type checking.
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
