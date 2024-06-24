import OSLog
import SwiftData
import SwiftUI

struct DBTaskView: View {
    static var label = "📬 DBTaskView::"

    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var diskManager: DiskManager
    @Environment(\.modelContext) var context

    @State var selection: String = ""

    @Query(sort: \CopyTask.createdAt, animation: .default) var tasks: [CopyTask]
    var label: String { "\(Logger.isMain)\(Self.label)" }
    
    init(verbose: Bool = false) {
        if verbose {
            os_log("\(Logger.isMain)\(Self.label)初始化")
        }
    }

    var body: some View {
        List(selection: $selection) {
            if tasks.count > 0 {
                Section(header: HStack {
                    Text("正在复制 \(tasks.count)")
                }, content: {
                    if tasks.count <= 5 {
                        ForEach(tasks) { task in
                            RowTask(task)
                        }
                        .onDelete(perform: { indexSet in
                            for i in indexSet {
                                diskManager.deleteCopyTask(tasks[i])
                            }
                        })
                    }
                })
            }
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
