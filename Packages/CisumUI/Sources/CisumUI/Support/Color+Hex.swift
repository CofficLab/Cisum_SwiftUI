import SwiftUI
#if os(macOS)
    import AppKit
#elseif os(iOS)
    import UIKit
#endif

extension Color {
    public init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    public static func adaptive(light: String, dark: String) -> Color {
        Color(light: light, dark: dark)
    }

    public init(light: String, dark: String) {
        #if os(macOS)
        self.init(nsColor: NSColor(name: nil) { appearance in
            if appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua {
                return NSColor(Color(hex: dark))
            } else {
                return NSColor(Color(hex: light))
            }
        })
        #elseif os(iOS)
        self.init(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(Color(hex: dark))
                : UIColor(Color(hex: light))
        })
        #else
        self.init(hex: light)
        #endif
    }

    /// 基于字符串（如人名）生成固定的自适应颜色，同一输入始终映射到同一色板项。
    public static func adaptive(from source: String) -> Color {
        let palette: [Color] = [
            Color(hex: "7C6FFF"),
            Color(hex: "FF6B6B"),
            Color(hex: "4ECDC4"),
            Color(hex: "FFB347"),
            Color(hex: "45B7D1"),
            Color(hex: "96CEB4"),
            Color(hex: "DDA0DD"),
            Color(hex: "F7DC6F"),
            Color(hex: "BB8FCE"),
            Color(hex: "85C1E9"),
            Color(hex: "F1948A"),
            Color(hex: "82E0AA"),
        ]

        var hash: UInt64 = 5381
        for byte in source.utf8 {
            hash = ((hash << 5) &+ hash) &+ UInt64(byte)
        }
        let index = Int(hash % UInt64(palette.count))
        return palette[max(0, index)]
    }

    /// 判断当前颜色在当前外观下是否为浅色（感知亮度 > 0.5）
    ///
    /// 使用 NSColor 解析后计算相对亮度，支持自适应颜色（adaptive color）。
    public var isLightColor: Bool {
        #if os(macOS)
        let nsColor = NSColor(self)
        guard let rgbColor = nsColor.usingColorSpace(.sRGB) else { return false }
        let r = Double(rgbColor.redComponent)
        let g = Double(rgbColor.greenComponent)
        let b = Double(rgbColor.blueComponent)
        #elseif os(iOS)
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        guard uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else { return false }
        let r = Double(red)
        let g = Double(green)
        let b = Double(blue)
        #else
        return false
        #endif
        // ITU-R BT.601 感知亮度公式
        let luminance = 0.299 * r + 0.587 * g + 0.114 * b
        return luminance > 0.5
    }
}
