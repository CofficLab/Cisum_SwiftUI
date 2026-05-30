#if os(macOS)
import CisumUI
import MagicAlert
import MagicKit
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
            title: String(localized: "暂无复制任务", table: "Audio-Copy-macOS", bundle: .module)
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
        HStack {
            Text("正在复制 \(tasks.count)", tableName: "Audio-Copy-macOS", bundle: .module)
            Spacer()
        }
    }

    private func deleteTasks(at offsets: IndexSet) {
        guard let container = AudioCopyService.container else {
            alert_error(String(localized: "Copy service is unavailable", table: "Audio-Copy-macOS", bundle: .module))
            return
        }

        let tasksToDelete = offsets.map { tasks[$0] }
        do {
            try CopyDB.deleteTasks(tasksToDelete, from: container)
            refreshTasks(postCountChanged: true)
        } catch {
            os_log(.error, "\(self.t)Delete failed: \(error.localizedDescription)")
            alert_error(String(localized: "Delete failed: \(error.localizedDescription)", table: "Audio-Copy-macOS", bundle: .module))
        }
    }
}
#endif
