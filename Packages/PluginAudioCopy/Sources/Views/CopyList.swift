#if os(macOS)
import CisumUIComponents
import OSLog
import SwiftData
import SwiftUI

struct CopyList: View, SuperLog, SuperThread {
    nonisolated static let emoji = "📬"

    @State private var selection: PersistentIdentifier?
    @State private var tasks: [CopyTask] = []

    init(verbose: Bool = false) {
        if verbose {
            os_log("\(Self.i)")
        }
    }

    var body: some View {
        Group {
            if !tasks.isEmpty {
                taskList
            } else {
                emptyView
            }
        }
        .onAppear {
            refreshTasks(postCountChanged: true)
        }
        .onCopyTaskCountChanged { _ in
            refreshTasks()
        }
        .onCopyTaskStarted { _ in
            refreshTasks()
        }
        .background(.regularMaterial)
        .cisumShadowSm()
    }

    /// 刷新任务列表
    private func refreshTasks(postCountChanged: Bool = false) {
        guard let container = AudioCopyService.container else {
            tasks = []
            return
        }
        tasks = CopyDB.getAllTasks(from: container)

        if postCountChanged {
            // 将最新数量通知出去，因为 CopyWorker 的数量通知有延迟。
            NotificationCenter.postCopyTaskCountChanged(count: tasks.count)
        }
    }

    /// 空视图
    private var emptyView: some View {
        AppEmptyState(
            icon: "tray",
            title: String(localized: "No copy tasks", bundle: .module)
        )
        .frame(minHeight: 160)
    }

    private var taskList: some View {
        List(selection: $selection) {
            Section {
                ForEach(tasks) { task in
                    AppListRow(isSelected: selection == task.id) {
                        VStack(alignment: .leading) {
                            Text(task.originalFilename)
                                .lineLimit(1)
                            Text(task.message)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .tag(task.id)
                }
                .onDelete(perform: deleteTasks)
            } header: {
                listHeader
            }
        }
        .frame(minWidth: 400)
    }

    private var listHeader: some View {
        let pendingCount = tasks.filter { $0.error.isEmpty }.count
        let failedCount = tasks.filter { !$0.error.isEmpty }.count

        return HStack {
            Text(CopyStatePresentation.message(pendingCount: pendingCount, failedCount: failedCount))
            Spacer()
        }
    }

    private func deleteTasks(at offsets: IndexSet) {
        guard let container = AudioCopyService.container else {
            alert_error(String(localized: "Copy service is unavailable", bundle: .module))
            return
        }

        guard let tasksToDelete = Self.tasksToDelete(from: offsets, in: tasks) else {
            alert_error(String(localized: "Delete failed: copy task list changed. Please try again.", bundle: .module))
            return
        }

        do {
            try CopyDB.deleteTasks(tasksToDelete, from: container)
            refreshTasks(postCountChanged: true)
        } catch {
            os_log(.error, "\(self.t)Delete failed: \(error.localizedDescription)")
            alert_error(String(localized: "Delete failed: \(error.localizedDescription)", bundle: .module))
        }
    }

    static func tasksToDelete(from offsets: IndexSet, in tasks: [CopyTask]) -> [CopyTask]? {
        var tasksToDelete: [CopyTask] = []
        tasksToDelete.reserveCapacity(offsets.count)

        for offset in offsets {
            guard tasks.indices.contains(offset) else {
                return nil
            }
            tasksToDelete.append(tasks[offset])
        }

        return tasksToDelete
    }
}
#endif
