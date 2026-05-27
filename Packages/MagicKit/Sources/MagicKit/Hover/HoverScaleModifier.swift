import SwiftUI

#if os(macOS)
    import AppKit
#else
    import UIKit
#endif

/// 悬停缩放修饰符
struct HoverScaleModifier: ViewModifier {
    let scale: CGFloat
    let duration: Double

    @State private var isHovering = false

    init(scale: CGFloat, duration: Double = 0.2) {
        self.scale = scale
        self.duration = duration
    }

    func body(content: Content) -> some View {
        #if os(macOS)
            content
                .scaleEffect(isHovering ? scale : 1.0)
                .animation(.easeInOut(duration: duration), value: isHovering)
                .onHover { hovering in
                    isHovering = hovering
                }
        #else
            // iOS 不支持鼠标悬停，直接返回原视图
            content
        #endif
    }
}
