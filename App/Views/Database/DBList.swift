import OSLog
import SwiftData
import SwiftUI

struct DBList: View {
    static var label = "📬 DBList::"

    @EnvironmentObject var appManager: AppManager
    @Environment(\.modelContext) private var modelContext

    @Query(Audio.descriptorAll, animation: .default) var audios: [Audio]
    @Query(sort: \CopyTask.createdAt, animation: .default) var tasks: [CopyTask]

    @State var selection: Audio? = nil
    @State var syncingTotal: Int = 0
    @State var syncingCurrent: Int = 0

    var total: Int { audios.count }
    var label: String { "\(Logger.isMain)\(Self.label)" }
    var showTips: Bool {
        if appManager.isDropping {
            return true
        }

        return appManager.flashMessage.isEmpty && total == 0
    }
    
    init(verbose: Bool = false) {
        if verbose {
            os_log("\(Logger.isMain)\(Self.label)初始化")
        }
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
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
                                        modelContext.delete(tasks[i])
                                    }
                                })
                            }
                        })
                    }

                    Section(header: HStack {
                        HStack {
                            Text("共 \(total.description)")

                            if syncingTotal > syncingCurrent {
                                Text("正在同步 \(syncingCurrent)/\(syncingTotal)")
                            }
                        }
                        Spacer()
                        if Config.isNotDesktop {
                            BtnAdd()
                                .font(.title2)
                                .labelStyle(.iconOnly)
                        }
                    }, content: {
                        ForEach(audios, id: \.self) { audio in
                            DBRow(audio.toPlayAsset())
                                .tag(audio as Audio?)
                        }
                    })
                    .task {
                        EventManager().onSyncing {
                            self.syncingTotal = $0
                            self.syncingCurrent = $1
                        }
                    }
                }
            }

            if showTips {
                DBTips().shadow(radius: 8)
            }
        }
    }
}

#Preview {
    LayoutView(width: 400, height: 800)
        .frame(height: 800)
}
