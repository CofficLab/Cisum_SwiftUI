import SwiftUI
import SwiftData

struct CopyTaskView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \CopyTask.createdAt, animation: .default) var tasks: [CopyTask]
    
    var body: some View {
        HStack {
            
//            List(tasks) {
//                Text("\($0.url.lastPathComponent)")
//            }
            Text("正在复制 \(tasks.count) 个文件")
                .font(.footnote)
                .foregroundStyle(.white)
        }
    }
}

#Preview {
    RootView {
        ContentView()
    }.modelContainer(AppConfig.getContainer())
}
