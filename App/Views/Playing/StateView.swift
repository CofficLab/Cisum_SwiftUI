import SwiftData
import SwiftUI

struct StateView: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var audioManager: AudioManager
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \CopyTask.createdAt, animation: .default) var tasks: [CopyTask]
    @Query(sort: \Audio.order, animation: .default) var audios: [Audio]

    @State var showList = false
    @State private var next: Audio?

    var taskCount: Int { tasks.count }
    var showCopyMessage: Bool { tasks.count > 0 }
    var audio: Audio? { audioManager.audio }
    var db: DB { audioManager.db }
    var count: Int { audios.count }
    var font: Font {
        if audio == nil {
            return .title3
        }

        return .callout
    }

    var body: some View {
        VStack {
            if appManager.stateMessage.count > 0 {
                makeInfoView(appManager.stateMessage)
            }

            // 播放过程中出现的错误
            if let e = audioManager.playerError {
                makeErrorView(e)
            }
            
            // 正在复制
            if tasks.count > 0 {
                HStack {
                    Text("正在复制 \(tasks.count) 个文件")
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
                    
                    BtnDelTask().padding(.leading, 24)
                }
            }
        }
        .onAppear {
            EventManager().onUpdated { items in
                for item in items {
                    if item.url == audioManager.audio?.url {
                        audioManager.checkError()
                        return
                    }
                }
            }
        }
        .onChange(of: count) {
            if audioManager.audio == nil, let first = db.first() {
                audioManager.prepare(first, reason: "自动设置为第一首")
            }

            if count == 0 {
                audioManager.prepare(nil, reason: "数据库个数变成了0")
            }

            audioManager.checkError()
        }
    }
    
    func makeInfoView(_ i: String) -> some View {
        CardView(background: BackgroundView.type3, paddingVertical: 6) {
            HStack {
                Image(systemName: "info.circle")
                    .foregroundStyle(.white)
                Text(i)
                    .foregroundStyle(.white)
            }
            .font(font)
        }
    }

    func makeErrorView(_ e: Error) -> some View {
        CardView(background: BackgroundView.type3, paddingVertical: 6) {
            HStack {
                Image(systemName: "info.circle")
                    .foregroundStyle(.white)
                Text(e.localizedDescription)
                    .foregroundStyle(.white)
            }
            .font(font)
        }
    }
    func delete(_ task: CopyTask) {
        modelContext.delete(task)
    }

    func copy(_ task: CopyTask) {
        try? CopyFiles().run(task, db: audioManager.db)
    }
}

#Preview("APP") {
    AppPreview()
}
