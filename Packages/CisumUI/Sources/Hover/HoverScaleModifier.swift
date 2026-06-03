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
    @LumiMotionPreferenceReader private var motionPreference

    init(scale: CGFloat, duration: Double = 0.2) {
        self.scale = scale
        self.duration = duration
    }

    func body(content: Content) -> some View {
        #if os(macOS)
            content
                .scaleEffect(isHovering && motionPreference.allowsMotion ? scale : 1.0)
                .animation(
                    LumiMotion.enabled(.easeOut(duration: duration), preference: motionPreference),
                    value: isHovering
                )
                .onHover { hovering in
                    LumiMotion.animate(LumiMotion.enabled(.easeOut(duration: duration), preference: motionPreference)) {
                        isHovering = hovering
                    }
                }
        #else
            // iOS 不支持鼠标悬停，直接返回原视图
            content
        #endif
    }
}
