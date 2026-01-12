import SwiftUI

struct LaunchDoneView: View, SuperLog {
    nonisolated static let verbose = true
    nonisolated static let emoji = "🚀"

    var errorMessage: String? = nil
    var isActive: Bool = false

    var body: some View {
        VStack {
            Spacer()
            MagicLoading(showProgress: false) {
                LogoView(background: .orange.opacity(0.8), rotationSpeed: 0.02, backgroundShape: .circle)
            }
            Spacer()
        }
        .onChange(of: isActive) { _, newValue in
            if newValue {
                emitLaunchDone()
            }
        }
        .onAppear() {
            if isActive {
                emitLaunchDone()
            }
        }
    }
}

// MARK: - Actions

extension LaunchDoneView {
    func emitLaunchDone() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            NotificationCenter.default.post(name: .launchDone, object: nil)
        }
    }
}

/// LaunchView 完成通知
extension Notification.Name {
    static let launchDone = Notification.Name("launchDone")
}

/// SwiftUI View 扩展，提供 LaunchView 事件监听
extension View {
    /// 监听 LaunchView 显示事件
    /// - Parameter action: LaunchView 显示时执行的操作
    /// - Returns: 添加了监听器的视图
    func onLaunchDone(perform action: @escaping () -> Void) -> some View {
        self.onReceive(NotificationCenter.default.publisher(for: .launchDone)) { _ in
            action()
        }
    }
}

// MARK: - Preview

#Preview("LaunchView") {
    LaunchDoneView()
        .frame(width: 300, height: 600)
        .inMagicContainer(.iMac27)
}

#Preview("LaunchView - Dark") {
    LaunchDoneView()
        .frame(width: 300, height: 600)
        .inMagicContainer(.iMac27)
        .preferredColorScheme(.dark)
}
