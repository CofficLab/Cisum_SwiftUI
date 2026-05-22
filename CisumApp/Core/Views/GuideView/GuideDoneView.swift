import CisumUI
import OSLog
import SwiftUI

struct GuideDoneView: View, SuperLog {
    nonisolated static let verbose = false
    nonisolated static let emoji = "🎯"

    var errorMessage: String? = nil
    var isActive: Bool = false

    @State private var hasScheduledNotification = false

    var body: some View {
        LogoView(rotationSpeed: 0.1)
            .padding()
            .cisumVStackCenter()
            .onChange(of: isActive, handleActiveChange)
            .onAppear(perform: handleOnAppear)
    }
}

// MARK: - Event Handler

extension GuideDoneView {
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
            NotificationCenter.postGuideDone()
        }
    }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
