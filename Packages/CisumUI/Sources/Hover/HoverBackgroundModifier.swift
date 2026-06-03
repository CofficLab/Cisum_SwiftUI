import SwiftUI

#if os(macOS)
    import AppKit
#else
    import UIKit
#endif

/// 悬停背景修饰符
struct HoverBackgroundModifier<S: ShapeStyle>: ViewModifier {
    let background: S
    let cornerRadius: CGFloat
    let duration: Double

    @State private var isHovering = false
    @LumiMotionPreferenceReader private var motionPreference

    init(background: S, cornerRadius: CGFloat = 8, duration: Double = 0.2) {
        self.background = background
        self.cornerRadius = cornerRadius
        self.duration = duration
    }

    func body(content: Content) -> some View {
        #if os(macOS)
            content
                .background {
                    if isHovering {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(background)
                    }
                }
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
