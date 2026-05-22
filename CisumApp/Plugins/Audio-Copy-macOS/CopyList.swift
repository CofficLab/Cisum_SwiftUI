#if os(macOS)
import CisumUI
import MagicKit
import OSLog
import SwiftData
import SwiftUI

struct CopyList: View, SuperLog, SuperThread {
    nonisolated static let emoji = "📬"

    @EnvironmentObject var app: AppProvider

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
            refreshTasks()
        }
        .onCopyTaskCountChanged { _ in
            refreshTasks()
        }
        .background(.regularMaterial)
        .shadowSm()
    }

    /// 刷新任务列表
    private func refreshTasks() {
        guard let container = CopyPlugin.container else {
            tasks = []
            return
        }
        tasks = CopyDB.getAllTasks(from: container)
        
        // 将最新数量通知出去，因为CopyWorker的数量通知有延迟
        NotificationCenter.postCopyTaskCountChanged(count: tasks.count)
    }

    /// 空视图
    private var emptyView: some View {
        AppEmptyState(
            icon: "tray",
            title: String(localized: "暂无复制任务", table: "Audio-Copy-macOS")
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
            Text("正在复制 \(tasks.count)", tableName: "Audio-Copy-macOS")
            Spacer()
        }
    }

    private func deleteTasks(at offsets: IndexSet) {
        guard let container = CopyPlugin.container else { return }
        let tasksToDelete = offsets.map { tasks[$0] }
        CopyDB.deleteTasks(tasksToDelete, from: container)
        refreshTasks()
    }
}

// MARK: Preview

#Preview("App") {
    ContentView()
        .inRootView()
        .withDebugBar()
}
#endif
