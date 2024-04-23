import OSLog
import SwiftData
import SwiftUI

struct DBList: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var audioManager: AudioManager
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Audio.order, animation: .default) var audios: [Audio]
    @Query(sort: \CopyTask.createdAt, animation: .default) var tasks: [CopyTask]
    
    @State var selection: Audio.ID? = nil

    var total: Int { db.getTotal() }
    var db: DB { audioManager.db }
    var audio: Audio? { audioManager.audio }
    var showTips: Bool {
        if appManager.isDropping {
            return true
        }
        
        return appManager.flashMessage.isEmpty && total == 0
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                List(selection: $selection) {
                    if tasks.count > 0 {
                        Section(header: HStack {
                            Text("正在复制 \(tasks.count)")
                        }, content: {
                            ForEach(tasks) { task in
                                RowTask(task)
                            }
                            .onDelete(perform: { indexSet in
                                for i in indexSet {
                                    modelContext.delete(tasks[i])
                                }
                            })
                        })
                    }
                    
                    Section(header: HStack {
                        Text("共 \(total.description)")
                        Spacer()
                        if ViewConfig.isNotDesktop {
                            BtnAdd()
                                .font(.title2)
                                .labelStyle(.iconOnly)
                        }
                    }, content: {
                        ForEach(audios) { audio in
                            Row(audio)
                        }
                        .onDelete(perform: { indexSet in
                            for i in indexSet {
                                db.delete(audios[i])
                            }
                        })
                    })
                }
            }
            
            if showTips {
                DBTips().shadow(radius: 8)
            }
        }
    }
}

#Preview {
    RootView {
        ContentView()
    }.modelContainer(AppConfig.getContainer())
}
