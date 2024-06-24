import OSLog
import SwiftData
import SwiftUI

struct DBViewList: View {
    static var label = "📬 DBList::"

    @EnvironmentObject var appManager: AppManager
    @Environment(\.modelContext) private var modelContext

    @Query(Audio.descriptorAll, animation: .default) var audios: [Audio]

    @State var selection: Audio? = nil
    @State var syncingTotal: Int = 0
    @State var syncingCurrent: Int = 0

    var total: Int { audios.count }
    var label: String { "\(Logger.isMain)\(Self.label)" }

    init(verbose: Bool = false) {
        if verbose {
            os_log("\(Logger.isMain)\(Self.label)初始化")
        }
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                List(selection: $selection) {
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
