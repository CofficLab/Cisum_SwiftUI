import CisumUI
import SwiftUI

struct CisumChromeTheme: LumiAppChromeTheme {
    let identifier: String
    let displayName: String
    let compactName: String
    let description: String
    let iconName: String
    let iconColor: Color
    let isDarkTheme: Bool
    let followsSystemAppearance: Bool

    let primary: Color
    let secondary: Color
    let tertiary: Color
    let deep: Color
    let medium: Color
    let light: Color
    let text: Color
    let secondaryText: Color
    let tertiaryText: Color

    func accentColors() -> (primary: Color, secondary: Color, tertiary: Color) {
        (primary, secondary, tertiary)
    }

    func atmosphereColors() -> (deep: Color, medium: Color, light: Color) {
        (deep, medium, light)
    }

    func glowColors() -> (subtle: Color, medium: Color, intense: Color) {
        (
            primary.opacity(0.12),
            secondary.opacity(0.2),
            tertiary.opacity(0.32)
        )
    }

    func workspaceBackgroundColor() -> Color {
        medium
    }

    func sidebarBackgroundColor() -> Color {
        deep
    }

    func workspaceTextColor() -> Color {
        text
    }

    func workspaceSecondaryTextColor() -> Color {
        secondaryText
    }

    func workspaceTertiaryTextColor() -> Color {
        tertiaryText
    }

    func makeGlobalBackground(proxy: GeometryProxy) -> AnyView {
        if identifier == "cisum" {
            return AnyView(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "FF512F").opacity(0.7),
                        Color(hex: "F09819").opacity(0.7),
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .background(.ultraThinMaterial)
                .ignoresSafeArea()
            )
        }

        return AnyView(
            LinearGradient(
                colors: [deep, medium, light.opacity(0.82), medium],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }
}

extension CisumChromeTheme {
    static let cisum = CisumChromeTheme(
        identifier: "cisum",
        displayName: "Cisum",
        compactName: "Cisum",
        description: "沿用原始日落渐变配色",
        iconName: "sunset.fill",
        iconColor: Color(hex: "FF512F"),
        isDarkTheme: false,
        followsSystemAppearance: true,
        primary: Color(hex: "FF512F"),
        secondary: Color(hex: "F09819"),
        tertiary: Color(hex: "4A90E2"),
        deep: Color(hex: "FF512F").opacity(0.18),
        medium: Color(hex: "F09819").opacity(0.14),
        light: Color(hex: "FFFFFF").opacity(0.34),
        text: .adaptive(light: "1C1C1E", dark: "FFFFFF"),
        secondaryText: .adaptive(light: "3A2A22", dark: "F5E6DC"),
        tertiaryText: .adaptive(light: "6F5147", dark: "D7B7A5")
    )

    static let midnight = CisumChromeTheme(
        identifier: "midnight",
        displayName: "午夜幽蓝",
        compactName: "午夜",
        description: "低亮度蓝黑背景，适合夜间听歌",
        iconName: "moon.stars.fill",
        iconColor: Color(hex: "60A5FA"),
        isDarkTheme: true,
        followsSystemAppearance: false,
        primary: Color(hex: "60A5FA"),
        secondary: Color(hex: "818CF8"),
        tertiary: Color(hex: "22D3EE"),
        deep: Color(hex: "020617"),
        medium: Color(hex: "0F172A"),
        light: Color(hex: "1E293B"),
        text: Color(hex: "F8FAFC"),
        secondaryText: Color(hex: "CBD5E1"),
        tertiaryText: Color(hex: "64748B")
    )

    static let aurora = CisumChromeTheme(
        identifier: "aurora",
        displayName: "极光紫",
        compactName: "极光",
        description: "冷紫与青绿交织，适合沉浸式播放页",
        iconName: "sparkles",
        iconColor: Color(hex: "C084FC"),
        isDarkTheme: true,
        followsSystemAppearance: false,
        primary: Color(hex: "A855F7"),
        secondary: Color(hex: "22D3EE"),
        tertiary: Color(hex: "34D399"),
        deep: Color(hex: "12091F"),
        medium: Color(hex: "1E1230"),
        light: Color(hex: "2F1F46"),
        text: Color(hex: "FAF5FF"),
        secondaryText: Color(hex: "DDD6FE"),
        tertiaryText: Color(hex: "A78BFA")
    )

    static let nebula = CisumChromeTheme(
        identifier: "nebula",
        displayName: "星云粉",
        compactName: "星云",
        description: "柔和粉紫氛围，保留清晰文本对比",
        iconName: "cloud.moon.fill",
        iconColor: Color(hex: "F0ABFC"),
        isDarkTheme: true,
        followsSystemAppearance: false,
        primary: Color(hex: "F0ABFC"),
        secondary: Color(hex: "FB7185"),
        tertiary: Color(hex: "C4B5FD"),
        deep: Color(hex: "1E1024"),
        medium: Color(hex: "2A1733"),
        light: Color(hex: "3B2247"),
        text: Color(hex: "FDF4FF"),
        secondaryText: Color(hex: "F5D0FE"),
        tertiaryText: Color(hex: "C084FC")
    )

    static let forest = CisumChromeTheme(
        identifier: "forest",
        displayName: "森林绿",
        compactName: "森林",
        description: "安静低饱和绿色，适合长时间听书",
        iconName: "leaf.fill",
        iconColor: Color(hex: "34D399"),
        isDarkTheme: true,
        followsSystemAppearance: false,
        primary: Color(hex: "34D399"),
        secondary: Color(hex: "A3E635"),
        tertiary: Color(hex: "2DD4BF"),
        deep: Color(hex: "07130D"),
        medium: Color(hex: "102018"),
        light: Color(hex: "1B3225"),
        text: Color(hex: "F0FDF4"),
        secondaryText: Color(hex: "BBF7D0"),
        tertiaryText: Color(hex: "86EFAC")
    )

    static let ocean = CisumChromeTheme(
        identifier: "ocean",
        displayName: "海洋蓝",
        compactName: "海洋",
        description: "清爽蓝青配色，随系统明暗适配",
        iconName: "water.waves",
        iconColor: .adaptive(light: "0284C7", dark: "38BDF8"),
        isDarkTheme: false,
        followsSystemAppearance: true,
        primary: .adaptive(light: "0284C7", dark: "38BDF8"),
        secondary: .adaptive(light: "0D9488", dark: "2DD4BF"),
        tertiary: .adaptive(light: "2563EB", dark: "60A5FA"),
        deep: .adaptive(light: "E0F2FE", dark: "061826"),
        medium: .adaptive(light: "F8FAFC", dark: "0C2433"),
        light: .adaptive(light: "BAE6FD", dark: "14384A"),
        text: .adaptive(light: "0F172A", dark: "F0F9FF"),
        secondaryText: .adaptive(light: "334155", dark: "BAE6FD"),
        tertiaryText: .adaptive(light: "64748B", dark: "7DD3FC")
    )

    static let sunset = CisumChromeTheme(
        identifier: "sunset",
        displayName: "日落橙",
        compactName: "日落",
        description: "暖色点缀主题，避免大面积高饱和",
        iconName: "sunset.fill",
        iconColor: Color(hex: "FB923C"),
        isDarkTheme: true,
        followsSystemAppearance: false,
        primary: Color(hex: "FB923C"),
        secondary: Color(hex: "F43F5E"),
        tertiary: Color(hex: "FACC15"),
        deep: Color(hex: "1C1008"),
        medium: Color(hex: "26180F"),
        light: Color(hex: "3A2416"),
        text: Color(hex: "FFF7ED"),
        secondaryText: Color(hex: "FED7AA"),
        tertiaryText: Color(hex: "FDBA74")
    )

    static let mono = CisumChromeTheme(
        identifier: "mono",
        displayName: "黑白高对比",
        compactName: "高对比",
        description: "黑白对比优先，提升可读性",
        iconName: "circle.lefthalf.filled",
        iconColor: Color(hex: "FFFFFF"),
        isDarkTheme: true,
        followsSystemAppearance: false,
        primary: Color(hex: "FFFFFF"),
        secondary: Color(hex: "D4D4D8"),
        tertiary: Color(hex: "A1A1AA"),
        deep: Color(hex: "000000"),
        medium: Color(hex: "09090B"),
        light: Color(hex: "18181B"),
        text: Color(hex: "FFFFFF"),
        secondaryText: Color(hex: "E4E4E7"),
        tertiaryText: Color(hex: "A1A1AA")
    )
}
