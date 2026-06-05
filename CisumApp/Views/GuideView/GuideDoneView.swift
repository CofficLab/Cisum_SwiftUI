import PluginRegistry
import OSLog
import SwiftUI

struct GuideDoneView: View, SuperLog {
    nonisolated static let verbose = false
    nonisolated static let emoji = "🎯"

    var errorMessage: String? = nil
    var isActive: Bool = false

    @State private var hasScheduledNotification = false
    @State private var notificationTask: Task<Void, Never>?

    var body: some View {
        LogoView(rotationSpeed: 0.1)
            .padding()
            .cisumVStackCenter()
            .onChange(of: isActive, handleActiveChange)
            .onAppear(perform: handleOnAppear)
            .onDisappear(perform: cancelScheduledNotification)
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
        } else {
            cancelScheduledNotification()
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

        notificationTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            guard !Task.isCancelled, isActive else { return }
            NotificationCenter.postGuideDone()
        }
    }

    private func cancelScheduledNotification() {
        notificationTask?.cancel()
        notificationTask = nil
        hasScheduledNotification = false
    }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
