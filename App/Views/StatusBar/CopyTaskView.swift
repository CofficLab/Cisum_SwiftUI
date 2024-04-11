import SwiftData
import SwiftUI

struct CopyTaskView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var audioManager: AudioManager

    @Query(sort: \CopyTask.createdAt, animation: .default) var tasks: [CopyTask]

    @State var showList = false

    var body: some View {
        if tasks.count > -10 {
            HStack {
                Spacer()
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
                        TableColumn("时间", value: \.time)
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
                    .frame(width: 800)
                })
                Spacer()
                Button(action: {
                    try? modelContext.delete(model: CopyTask.self)
                }, label: {
                    Image(systemName: "trash")
                })
                .labelStyle(.iconOnly)
                .buttonStyle(PlainButtonStyle())
                .padding(.trailing, 4)
            }
        }
    }

    func delete(_ task: CopyTask) {
        modelContext.delete(task)
    }

    func copy(_ task: CopyTask) {
        try? CopyFiles().run(task, db: audioManager.db)
    }
}

#Preview {
    RootView {
        ContentView()
    }.modelContainer(AppConfig.getContainer())
}
