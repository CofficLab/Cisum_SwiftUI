import SwiftUI

public extension View {
    /// 将视图包装在 MacDesktop 中
    /// 创建一个模拟 macOS 桌面的布局，包含顶部任务栏和底部 Dock
    func inDesktop() -> some View {
        MacDesktop {
            self
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Desktop Layout - Large") {
    Text("Hello, World!")
        .font(.title)
        .foregroundColor(.white)
        .inDesktop()
        .frame(width: 1200, height: 800)
}

#if DEBUG
#Preview("Desktop Layout - Small") {
    Text("Hello, World!")
        .font(.title)
        .foregroundColor(.white)
        .inDesktop()
        .frame(width: 800, height: 600)
}
#endif
#endif
