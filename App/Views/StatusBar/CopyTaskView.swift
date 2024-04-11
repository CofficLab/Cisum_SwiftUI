import SwiftData
import SwiftUI

struct CopyTaskView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \CopyTask.createdAt, animation: .default) var tasks: [CopyTask]

    @State var showList = false

    var body: some View {
        if tasks.count > 0 {
            HStack {
                Text("正在复制 \(tasks.count) 个文件")
                    .font(.footnote)
                    .foregroundStyle(.white)
                Button(action: {
                    showList = true
                }, label: {
                    Image(systemName: "list.bullet").foregroundStyle(.white)
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
        do {
            try CopyFiles().run(task, context: modelContext)
        } catch let e {
            task.error = e.localizedDescription
            task.succeed = false
            task.finished = true
        }
        
        try? modelContext.save()
    }
}

#Preview {
    RootView {
        ContentView()
    }.modelContainer(AppConfig.getContainer())
}
