import SwiftUI

/// 营销 / 仪表盘用渐变配色（与 ``LumiUITheme`` 组件主题无关）。
public struct AppTheme {
    public struct Colors {
        public static let primary = Color("AccentColor")
        public static let background = Color(nsColor: .windowBackgroundColor)

        public static let gradientStart = Color(hex: "4facfe")
        public static let gradientEnd = Color(hex: "00f2fe")

        public static func gradient(for type: GradientType) -> LinearGradient {
            switch type {
            case .blue:
                return LinearGradient(
                    colors: [Color(hex: "4facfe"), Color(hex: "00f2fe")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case .purple:
                return LinearGradient(
                    colors: [Color(hex: "a18cd1"), Color(hex: "fbc2eb")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case .orange:
                return LinearGradient(
                    colors: [Color(hex: "f6d365"), Color(hex: "fda085")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case .green:
                return LinearGradient(
                    colors: [Color(hex: "84fab0"), Color(hex: "8fd3f4")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case .primary:
                return LinearGradient(
                    colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
    }

    public enum GradientType {
        case blue, purple, orange, green, primary
    }
}
