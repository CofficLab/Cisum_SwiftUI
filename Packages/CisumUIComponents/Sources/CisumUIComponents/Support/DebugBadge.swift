import SwiftUI

#if DEBUG
/// 调试徽章 + 虚线边框 —— 仅 DEBUG 构建下叠加在目标视图上。
///
/// 用于快速识别当前渲染的视图及其边界：右上角显示视图标识（badge），
/// 四周绘制一圈虚线边框。Release 构建下不编译任何代码。
public struct DebugBadgeModifier: ViewModifier {
    public let text: String
    public let color: Color

    public init(text: String, color: Color = .red) {
        self.text = text
        self.color = color
    }

    public func body(content: Content) -> some View {
        content
            .overlay {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(color.opacity(0.55), style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                    .allowsHitTesting(false)
            }
            .overlay(alignment: .topTrailing) {
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
}

public extension View {
    /// 叠加调试徽章与虚线边框（仅 DEBUG 构建生效）。
    /// - Parameters:
    ///   - text: 徽章文本（通常为视图或插件 id）。
    ///   - color: 徽章与边框主色，默认红色。
    func debugBadge(_ text: String, color: Color = .red) -> some View {
        modifier(DebugBadgeModifier(text: text, color: color))
    }
}
#endif
