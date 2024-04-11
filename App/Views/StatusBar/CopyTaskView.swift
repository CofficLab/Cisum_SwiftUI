import SwiftData
import SwiftUI

struct CopyTaskView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \CopyTask.createdAt, animation: .default) var tasks: [CopyTask]

    @State var showList = false

    var body: some View {
        if tasks.count > -10 {
            HStack {
                Text("正在复制 \(tasks.count) 个文件")
                    .font(.footnote)
                Button(action: {
                    showList = true
                }, label: {
                    Image(systemName: "list.bullet")
                })
                .labelStyle(.iconOnly)
                .buttonStyle(PlainButtonStyle())
                .popover(isPresented: $showList, content: {
                    Table(tasks, columns: {
                        TableColumn("文件", value: \.title)
                        TableColumn("结果", value: \.message)
                        TableColumn("操作") { task in
                            HStack {
                                Button("复制", action: {
                                    copy(task)
                                })
                                Button("删除", action: {
                                    delete(task)
                                })
                            }
                        }
                    })
                    .frame(width: 600)
                })
            }
            .onAppear {
                for task in tasks {
                    copy(task)
                }
            }
        }
    }
    
    func delete(_ task: CopyTask) {
        modelContext.delete(task)
    }
    
    func copy(_ task: CopyTask) {
        if task.isRunning {
            return
        }
        
        try? CopyFiles().run(task, context: modelContext)
    }
}

#Preview {
    RootView {
        ContentView()
    }.modelContainer(AppConfig.getContainer())
}
