import OSLog
import SwiftData
import SwiftUI
import MagicKit

struct CopyView: View, SuperLog, SuperThread {
    static let emoji = "📬"

    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var audioManager: AudioProvider
    @Environment(\.modelContext) private var context

    @State private var selection: String?

    @Query(sort: \CopyTask.createdAt, animation: .default) private var tasks: [CopyTask]

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
                Text("没有复制任务")
            }
        }
        .onChange(of: tasks.count) {
            os_log("\(self.t)Task count changed to \(tasks.count)")
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
//            dataManager.deleteCopyTask(tasks[index])
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
