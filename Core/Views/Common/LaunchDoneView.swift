import OSLog
import SwiftUI

struct LaunchDoneView: View, SuperLog {
    nonisolated static let verbose = true
    nonisolated static let emoji = "🚀"

    var errorMessage: String? = nil
    var isActive: Bool = false

    @State private var hasScheduledNotification = false

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
            scheduleNotification()
        }
    }

    /// 处理视图出现事件
    func handleOnAppear() {
        if isActive {
            scheduleNotification()
        }
    }

    /// 调度通知发送（延迟1秒）
    private func scheduleNotification() {
        // 避免重复调度
        guard !hasScheduledNotification else { return }

        hasScheduledNotification = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            NotificationCenter.postLaunchDone()
        }
    }
}

// MARK: - Preview

#if os(macOS)
    #Preview("App - Large") {
        ContentView()
            .inRootView()
            .frame(width: 600, height: 1000)
    }

    #Preview("App - Small") {
        ContentView()
            .inRootView()
            .frame(width: 400, height: 700)
    }
#endif

#if os(iOS)
    #Preview("iPhone") {
        ContentView()
            .inRootView()
    }
#endif
