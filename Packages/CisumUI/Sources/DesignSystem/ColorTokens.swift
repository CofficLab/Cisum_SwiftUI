//
//  ColorTokens.swift
//  Lumi
//
//  Created by Design System on 2025-02-11.
//  设计令牌 - 颜色系统
//

import SwiftUI

// MARK: - 颜色系统
///
/// 定义应用中所有颜色相关的设计令牌。
/// 包括基础色板、语义化颜色和渐变色。
/// 现在支持浅色/深色模式自动适配。
///
extension DesignTokens {
    enum Color {
        // MARK: - 响应式颜色（支持浅色/深色模式）
        /// 响应式语义化颜色 - 根据 ColorScheme 自动适配
        /// 使用 @Environment(\.colorScheme) 获取当前配色方案
        static let adaptive = AdaptiveSemanticColors()

        // MARK: - 基础色板（保持向后兼容）
        /// 基础色调（神秘深色）
        static let basePalette = BasePalette()

        /// 语义化颜色（静态，仅用于深色模式）
        /// ⚠️ 建议使用 adaptive 替代
        static let semantic = SemanticColors()

        /// 渐变色
        static let gradients = GradientColors()

        // MARK: - 基础色调
        /// 基础色调 - 定义应用的基础背景和氛围色
        struct BasePalette {
            // 深色背景（OLED 优化）
            let deepBackground = SwiftUI.Color(hex: "050508")      // 接近纯黑，带神秘蓝调
            let surfaceBackground = SwiftUI.Color(hex: "0D0D12")   // 卡片表面
            let elevatedSurface = SwiftUI.Color(hex: "14141A")     // 悬浮表面
            let overlayBackground = SwiftUI.Color(hex: "1A1A22")   // 叠加层

            // 神秘氛围色
            let mysticIndigo = SwiftUI.Color(hex: "1E1B2E")       // 靛紫
            let mysticViolet = SwiftUI.Color(hex: "2D1B3D")       // 紫罗兰
            let mysticAzure = SwiftUI.Color(hex: "0B1A2E")         // 深蔚蓝

            // 高光和边框
            let subtleBorder = SwiftUI.Color(hex: "FFFFFF")        // 微妙白边
            let glowAccent = SwiftUI.Color(hex: "6B5CE7")         // 幽光紫
        }

        // MARK: - 语义化颜色
        /// 语义化颜色 - 具有特定含义的颜色
        struct SemanticColors {
            // 主色调
            let primary = SwiftUI.Color.adaptive(light: "7C6FFF", dark: "7C6FFF")             // 主紫
            let primarySecondary = SwiftUI.Color.adaptive(light: "A99CFF", dark: "A99CFF")    // 次紫

            // 状态色
            let success = SwiftUI.Color.adaptive(light: "30D158", dark: "30D158")             // 成功绿
            let successGlow = SwiftUI.Color.adaptive(light: "7CFFB5", dark: "7CFFB5")         // 成功光晕
            let warning = SwiftUI.Color.adaptive(light: "FF9F0A", dark: "FF9F0A")             // 警告橙
            let warningGlow = SwiftUI.Color.adaptive(light: "FFD57F", dark: "FFD57F")         // 警告光晕
            let error = SwiftUI.Color.adaptive(light: "FF453A", dark: "FF453A")               // 错误红
            let errorGlow = SwiftUI.Color.adaptive(light: "FF7A73", dark: "FF7A73")           // 错误光晕
            let info = SwiftUI.Color.adaptive(light: "0A84FF", dark: "0A84FF")                // 信息蓝
            let infoGlow = SwiftUI.Color.adaptive(light: "7AB8FF", dark: "7AB8FF")            // 信息光晕

            // 文本色（确保 WCAG AA 对比度 ≥ 4.5:1）
            let textPrimary = SwiftUI.Color.adaptive(light: "1C1C1E", dark: "FFFFFF")         // 主要文本
            let textSecondary = SwiftUI.Color.adaptive(light: "6B6B7B", dark: "EBEBF5")       // 次要文本
            let textTertiary = SwiftUI.Color.adaptive(light: "98989E", dark: "98989E")        // 三级文本
            let textDisabled = SwiftUI.Color.adaptive(light: "BDBDBD", dark: "48484F")        // 禁用文本
        }

        // MARK: - 渐变色
        /// 渐变色 - 预定义的渐变效果
        struct GradientColors {
            // 主渐变（神秘紫）
            var primaryGradient = LinearGradient(
                colors: [
                    SwiftUI.Color(hex: "7C6FFF"),
                    SwiftUI.Color(hex: "B4A5FF")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // 深海渐变
            var oceanGradient = LinearGradient(
                colors: [
                    SwiftUI.Color(hex: "0A1A3E"),
                    SwiftUI.Color(hex: "1A2A5E")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // 极光渐变
            var auroraGradient = LinearGradient(
                colors: [
                    SwiftUI.Color(hex: "6B5CE7"),
                    SwiftUI.Color(hex: "A78BFA"),
                    SwiftUI.Color(hex: "38BDF8")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // 能量渐变（用于进度、活跃状态）
            var energyGradient = LinearGradient(
                colors: [
                    SwiftUI.Color(hex: "00D4FF"),
                    SwiftUI.Color(hex: "7C6FFF")
                ],
                startPoint: .leading,
                endPoint: .trailing
            )

            // 发光边框渐变
            var glowBorderGradient = LinearGradient(
                colors: [
                    SwiftUI.Color.clear,
                    SwiftUI.Color.white.opacity(0.08),
                    SwiftUI.Color.clear
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    // MARK: - 响应式语义化颜色
    /// 响应式语义化颜色 - 根据 ColorScheme 自动适配
    /// 提供动态颜色选择，支持浅色和深色模式
    struct AdaptiveSemanticColors {
        // MARK: - 环境依赖的颜色计算

        /// 主要文本色（根据配色方案动态调整）
        func textPrimary(for scheme: ColorScheme) -> SwiftUI.Color {
            switch scheme {
            case .light:
                SwiftUI.Color(hex: "1C1C1E")  // 深色文本（浅色模式）
            case .dark:
                SwiftUI.Color(hex: "FFFFFF")  // 白色文本（深色模式）
            @unknown default:
                SwiftUI.Color(hex: "FFFFFF")
            }
        }

        /// 次要文本色
        func textSecondary(for scheme: ColorScheme) -> SwiftUI.Color {
            switch scheme {
            case .light:
                SwiftUI.Color(hex: "6B6B7B")  // 中灰文本（浅色模式）
            case .dark:
                SwiftUI.Color(hex: "EBEBF5")  // 浅白文本（深色模式）
            @unknown default:
                SwiftUI.Color(hex: "EBEBF5")
            }
        }

        /// 三级文本色
        func textTertiary(for scheme: ColorScheme) -> SwiftUI.Color {
            switch scheme {
            case .light, .dark:
                SwiftUI.Color(hex: "98989E")  // 紫灰文本（两种模式都可用）
            @unknown default:
                SwiftUI.Color(hex: "98989E")
            }
        }

        /// 禁用文本色
        func textDisabled(for scheme: ColorScheme) -> SwiftUI.Color {
            switch scheme {
            case .light:
                SwiftUI.Color(hex: "BDBDBD")  // 浅灰（浅色模式）
            case .dark:
                SwiftUI.Color(hex: "48484F")  // 深灰（深色模式）
            @unknown default:
                SwiftUI.Color(hex: "48484F")
            }
        }

        // MARK: - 背景色

        /// 深色背景色
        func deepBackground(for scheme: ColorScheme) -> SwiftUI.Color {
            switch scheme {
            case .light:
                SwiftUI.Color(hex: "F5F5F7")  // 浅灰紫背景（浅色模式）
            case .dark:
                SwiftUI.Color(hex: "050508")  // 深色背景（深色模式）
            @unknown default:
                SwiftUI.Color(hex: "050508")
            }
        }

        /// 卡片表面背景色
        func surfaceBackground(for scheme: ColorScheme) -> SwiftUI.Color {
            switch scheme {
            case .light:
                SwiftUI.Color(hex: "FFFFFF")  // 纯白卡片（浅色模式）
            case .dark:
                SwiftUI.Color(hex: "0D0D12")  // 深色卡片（深色模式）
            @unknown default:
                SwiftUI.Color(hex: "0D0D12")
            }
        }

        /// 悬浮表面背景色
        func elevatedSurface(for scheme: ColorScheme) -> SwiftUI.Color {
            switch scheme {
            case .light:
                SwiftUI.Color(hex: "FFFFFF")  // 纯白（浅色模式）
            case .dark:
                SwiftUI.Color(hex: "14141A")  // 悬浮深色（深色模式）
            @unknown default:
                SwiftUI.Color(hex: "14141A")
            }
        }

        /// 叠加层背景色
        func overlayBackground(for scheme: ColorScheme) -> SwiftUI.Color {
            switch scheme {
            case .light:
                SwiftUI.Color(hex: "E5E5EA")  // 浅灰叠加（浅色模式）
            case .dark:
                SwiftUI.Color(hex: "1A1A22")  // 深色叠加（深色模式）
            @unknown default:
                SwiftUI.Color(hex: "1A1A22")
            }
        }

        /// 分隔线颜色
        func divider(for scheme: ColorScheme) -> SwiftUI.Color {
            switch scheme {
            case .light:
                SwiftUI.Color(hex: "E5E5EA").opacity(0.5)  // 浅灰分隔线
            case .dark:
                SwiftUI.Color(hex: "FFFFFF").opacity(0.15)  // 白色分隔线
            @unknown default:
                SwiftUI.Color(hex: "FFFFFF").opacity(0.15)
            }
        }

        // MARK: - 主题色（保持不变）

        /// 主色调（两种模式保持一致）
        let primary = SwiftUI.Color(hex: "7C6FFF")
        let primarySecondary = SwiftUI.Color(hex: "A99CFF")

        /// 主渐变（两种模式保持一致）
        func primaryGradient(for scheme: ColorScheme) -> LinearGradient {
            // 两种模式使用相同的主题渐变，保持品牌一致性
            LinearGradient(
                colors: [
                    SwiftUI.Color(hex: "7C6FFF"),
                    SwiftUI.Color(hex: "B4A5FF")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }

        /// 错误红（根据配色方案调整）
        func error(for scheme: ColorScheme) -> SwiftUI.Color {
            switch scheme {
            case .light:
                SwiftUI.Color(hex: "FF3B30")  // 浅色模式：更醒目的红色
            case .dark:
                SwiftUI.Color(hex: "FF453A")  // 深色模式：系统错误红
            @unknown default:
                SwiftUI.Color(hex: "FF453A")
            }
        }

        /// 错误色背景（用于危险按钮等）
        func errorBackground(for scheme: ColorScheme) -> SwiftUI.Color {
            switch scheme {
            case .light:
                SwiftUI.Color(hex: "FF3B30").opacity(0.1)  // 浅色模式：浅红背景
            case .dark:
                SwiftUI.Color(hex: "FF453A").opacity(0.2)  // 深色模式：深红背景
            @unknown default:
                SwiftUI.Color(hex: "FF453A").opacity(0.2)
            }
        }

        // 状态色
        let success = SwiftUI.Color(hex: "30D158")
        let successGlow = SwiftUI.Color(hex: "7CFFB5")
        let warning = SwiftUI.Color(hex: "FF9F0A")
        let warningGlow = SwiftUI.Color(hex: "FFD57F")
        let error = SwiftUI.Color(hex: "FF453A")
        let errorGlow = SwiftUI.Color(hex: "FF7A73")
        let info = SwiftUI.Color(hex: "0A84FF")
        let infoGlow = SwiftUI.Color(hex: "7AB8FF")

        // MARK: - 材质效果

        /// 神秘氛围材质（根据模式调整透明度）
        func mysticGlassMaterial(for scheme: ColorScheme) -> some ShapeStyle {
            switch scheme {
            case .light:
                SwiftUI.Color.white.opacity(0.7)  // 浅色模式：白色半透明
            case .dark:
                SwiftUI.Color.black.opacity(0.3)  // 深色模式：黑色半透明
            @unknown default:
                SwiftUI.Color.black.opacity(0.3)
            }
        }

        /// 光晕强度（根据模式调整）
        func glowIntensity(for scheme: ColorScheme) -> Double {
            switch scheme {
            case .light:
                return 0.06  // 浅色模式：较弱的光晕（避免过度曝光）
            case .dark:
                return 0.15  // 深色模式：正常光晕
            @unknown default:
                return 0.15
            }
        }

        /// 边框透明度
        func borderOpacity(for scheme: ColorScheme) -> Double {
            switch scheme {
            case .light:
                return 0.3  // 浅色模式：较淡的边框
            case .dark:
                return 0.15  // 深色模式：标准边框
            @unknown default:
                return 0.15
            }
        }
    }
}
