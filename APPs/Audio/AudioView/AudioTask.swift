import OSLog
import SwiftData
import SwiftUI
import MagicKit

struct AudioTask: View, SuperLog, SuperThread {
    let emoji = "📬"

    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var dataManager: DataProvider
    @Environment(\.modelContext) private var context

    @State private var selection: String?

    @Query(sort: \CopyTask.createdAt, animation: .default) private var tasks: [CopyTask]

    init(verbose: Bool = false) {
        if verbose {
            os_log("\(Logger.isMain)AudioTask")
        }
    }

    var body: some View {
        Group {
            if !tasks.isEmpty && app.showCopying {
                taskList
            }
        }
        .onChange(of: tasks.count) { newCount in
            if newCount == 0 {
                app.showCopying = false
            }
        }
    }

    private var taskList: some View {
        List(selection: $selection) {
            Section {
                ForEach(tasks, id: \.url.relativeString) { task in
                    RowTask(task)
                }
                .onDelete(perform: deleteTasks)
            } header: {
                listHeader
            }
        }
    }

    private var listHeader: some View {
        HStack {
            Text("正在复制 \(tasks.count)")
            Spacer()
            Button("关闭", systemImage: "xmark.circle") {
                app.showCopying = false
            }
            .labelStyle(.iconOnly)
        }
    }

    private func deleteTasks(at offsets: IndexSet) {
        for index in offsets {
            dataManager.deleteCopyTask(tasks[index])
        }
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}

#Preview {
    LayoutView(width: 400, height: 800)
        .frame(height: 800)
}
