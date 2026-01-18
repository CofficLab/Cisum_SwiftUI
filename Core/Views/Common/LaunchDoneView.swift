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
        .onChange(of: isActive, handleActiveChange)
        .onAppear(perform: handleOnAppear)
    }
}

// MARK: - Event Handler

extension LaunchDoneView {
    /// 处理激活状态变化
    /// - Parameters:
    ///   - oldValue: 旧的激活状态值
    ///   - newValue: 新的激活状态值
    func handleActiveChange(_ oldValue: Bool, _ newValue: Bool) {
        if newValue {
            NotificationCenter.postLaunchDone()
        }
    }

    /// 处理视图出现事件
    func handleOnAppear() {
        if isActive {
            NotificationCenter.postLaunchDone()
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
