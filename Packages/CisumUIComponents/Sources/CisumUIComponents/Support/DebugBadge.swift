import SwiftUI

#if DEBUG
/// 调试徽章 + 虚线边框 —— 仅 DEBUG 构建下叠加在目标视图上。
///
/// 用于快速识别当前渲染的视图及其边界：角部显示视图标识（badge），
/// 四周绘制一圈虚线边框。Release 构建下不编译任何代码。
///
/// 颜色默认根据视图标识（`text`）确定性派生——不同视图得到不同颜色，
/// 同一视图颜色稳定，便于在多视图叠加时一眼区分来源。
public struct DebugBadgeModifier: ViewModifier {
    public let text: String
    public let color: Color
    public let alignment: Alignment

    public init(text: String, color: Color? = nil, alignment: Alignment = .topTrailing) {
        self.text = text
        self.color = color ?? Self.randomColor(for: text)
        self.alignment = alignment
    }

    public func body(content: Content) -> some View {
        content
            .overlay {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(color.opacity(0.55), style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                    .allowsHitTesting(false)
            }
            .overlay(alignment: alignment) {
                Text(text)
                    .font(.caption2.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .foregroundStyle(.white)
                    .background(color.opacity(0.85), in: Capsule())
                    .overlay(Capsule().strokeBorder(.white.opacity(0.5), lineWidth: 0.5))
                    .shadow(color: .black.opacity(0.25), radius: 3, y: 1)
                    .allowsHitTesting(false)
                    .padding(8)
            }
    }

    /// 依据标识生成稳定的随机色相（不同标识 → 不同颜色）。
    static func randomColor(for text: String) -> Color {
        var hash: UInt64 = 5381
        for byte in text.utf8 {
            hash = ((hash << 5) &+ hash) &+ UInt64(byte)
        }
        let hue = Double(hash % 360) / 360.0
        return Color(hue: hue, saturation: 0.62, brightness: 0.78)
    }
}

public extension View {
    /// 叠加调试徽章与虚线边框（仅 DEBUG 构建生效）。
    /// - Parameters:
    ///   - text: 徽章文本（通常为视图或插件 id）。
    ///   - color: 徽章与边框主色；默认根据 `text` 确定性派生随机色。
    ///   - alignment: 徽章在视图中的对齐位置；默认右上角（`.topTrailing`）。
    func debugBadge(_ text: String, color: Color? = nil, alignment: Alignment = .topTrailing) -> some View {
        modifier(DebugBadgeModifier(text: text, color: color, alignment: alignment))
    }
}
#endif
