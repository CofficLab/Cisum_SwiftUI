#if os(macOS)
import CisumUI
import OSLog
import SwiftData
import SwiftUI

enum CopyStatePresentation {
    static func detailsButtonLabel(isShowing: Bool) -> String {
        String(
            localized: isShowing ? "Hide copy details" : "Show copy details",
            bundle: .module
        )
    }

    static func message(pendingCount: Int, failedCount: Int) -> String {
        if pendingCount > 0, failedCount > 0 {
            return String(
                localized: "Copying \(pendingCount) \(fileLabel(for: pendingCount)), \(failedCount) failed",
                bundle: .module
            )
        }

        if pendingCount > 0 {
            return String(
                localized: "Copying \(pendingCount) \(fileLabel(for: pendingCount))",
                bundle: .module
            )
        }

        if failedCount > 0 {
            return String(
                localized: "\(failedCount) \(taskLabel(for: failedCount)) failed",
                bundle: .module
            )
        }

        return ""
    }

    private static func fileLabel(for count: Int) -> String {
        count == 1 ? String(localized: "file", bundle: .module) : String(localized: "files", bundle: .module)
    }

    private static func taskLabel(for count: Int) -> String {
        count == 1 ? String(localized: "copy task", bundle: .module) : String(localized: "copy tasks", bundle: .module)
    }
}

struct CopyStateView: View, SuperLog, SuperThread {
    @State private var showCopying = false
    @State private var taskCount: Int = 0
    @State private var pendingCount: Int = 0
    @State private var failedCount: Int = 0

    nonisolated static let emoji = "🖥️"
    nonisolated static var verbose: Bool { false }

    /// 是否应该显示状态视图
    private var shouldShow: Bool {
        taskCount > 0
    }

    var body: some View {
        Group {
            if shouldShow {
                HStack {
                    Image(systemName: "info.circle")
                    Text(CopyStatePresentation.message(pendingCount: pendingCount, failedCount: failedCount))
                    Image.cisumList.cisumButton {
                        self.showCopying.toggle()
                    }
                    .accessibilityLabel(CopyStatePresentation.detailsButtonLabel(isShowing: showCopying))
                    .help(CopyStatePresentation.detailsButtonLabel(isShowing: showCopying))
                }
                .font(.callout)
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(CisumMagicBackground.deepForest)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .contentTransition(.numericText(value: Double(taskCount)))
                .popover(isPresented: $showCopying) {
                    CopyList()
                }
                .transition(.opacity.combined(with: .scale))
                .cisumShadowSm()
            }
        }
        .onCopyTaskCountChanged(perform: handleCopyTaskCountChanged)
        .onCopyTaskFinished(perform: handleCopyTaskFinished)
        .onAppear(perform: handleAppear)
    }
}

// MARK: - View

extension CopyStateView {
    func makeInfoView(_ i: String) -> some View {
        HStack {
            Image(systemName: "info.circle")
                .foregroundStyle(.white)
            Text(i)
                .foregroundStyle(.white)
        }
        .cisumCard()
        .font(.title3)
    }
}

// MARK: - Event Handler

extension CopyStateView {
    func handleAppear() {
        Task { @MainActor in
            let tasks = await refreshTaskCounts()

            guard tasks.contains(where: { $0.error.isEmpty }),
                  let worker = AudioCopyService.getWorker() else {
                return
            }

            await worker.run()
        }
    }

    func handleCopyTaskCountChanged(_ count: Int) {
        Task { @MainActor in
            let tasks = await refreshTaskCounts()
            if tasks.isEmpty, count > 0 {
                taskCount = count
                pendingCount = count
                failedCount = 0
            }
        }
    }

    func handleCopyTaskFinished(_ lastCount: Int) {
        // 任务完成，清零任务数量
        taskCount = 0
        pendingCount = 0
        failedCount = 0
        alert_info(String(localized: "Copy completed", bundle: .module))
    }

    @discardableResult
    private func refreshTaskCounts() async -> [CopyTaskDTO] {
        guard let db = AudioCopyService.getDB() else {
            taskCount = 0
            pendingCount = 0
            failedCount = 0
            return []
        }

        let tasks = await db.allCopyTaskDTOs()
        taskCount = tasks.count
        pendingCount = tasks.filter { $0.error.isEmpty }.count
        failedCount = tasks.filter { !$0.error.isEmpty }.count
        return tasks
    }
}
#endif
