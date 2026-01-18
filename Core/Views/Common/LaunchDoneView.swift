import OSLog
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
            handleActiveChange(newValue)
        }
        .onAppear(perform: handleOnAppear)
    }
}

// MARK: - Event Handler

extension LaunchDoneView {
    /// 处理激活状态变化
    /// - Parameter newValue: 新的激活状态值
    func handleActiveChange(_ newValue: Bool) {
        if newValue {
            emitLaunchDone()
        }
    }

    /// 处理视图出现事件
    func handleOnAppear() {
        if isActive {
            emitLaunchDone()
        }
    }
}

// MARK: - Actions

extension LaunchDoneView {
    func emitLaunchDone() {
        if Self.verbose {
            os_log("\(Self.t)🚀 准备发送启动完成通知")
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            NotificationCenter.postLaunchDone()
            if LaunchDoneView.verbose {
                os_log("\(LaunchDoneView.t)✅ 启动完成通知已发送")
            }
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
