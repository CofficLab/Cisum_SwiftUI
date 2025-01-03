import OSLog
import SwiftData
import SwiftUI
import MagicKit
import MagicUI

struct CopyList: View, SuperLog, SuperThread {
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
            }
        }
    }

    private var taskList: some View {
        List(selection: $selection) {
            Section {
                ForEach(tasks, id: \.url.relativeString) { task in
                    task.url.copyView(destination: task.destination, onCompletion: { error in
                        if let error = error {
                            task.error = error.localizedDescription
                            try? context.save()
                        } else {
                            context.delete(task)
                        }
                    })
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
        }
    }

    private func deleteTasks(at offsets: IndexSet) {
        for index in offsets {
            context.delete(tasks[index])
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
