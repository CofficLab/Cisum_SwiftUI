import OSLog
import SwiftData
import SwiftUI

struct DBViewList: View {
    static var label = "📬 DBList::"

    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var playMan: PlayMan
    @Environment(\.modelContext) private var modelContext

    @Query(Audio.descriptorAll, animation: .default) var audios: [Audio]

    @State var selection: Audio? = nil

    var total: Int { audios.count }
    var label: String { "\(Logger.isMain)\(Self.label)" }

    init(verbose: Bool = false) {
        if verbose {
            os_log("\(Logger.isMain)\(Self.label)初始化")
        }
    }

    var body: some View {
        Section(header: HStack {
            Text("共 \(total.description)")
            Spacer()
            if Config.isNotDesktop {
                BtnAdd()
                    .font(.title2)
                    .labelStyle(.iconOnly)
            }
        }, content: {
            List(audios, id: \.self, children: \.children, selection: $selection) { audio in
                if let children = audio.children {
                    Text(audio.title)
                } else {
                    DBRow(audio.toPlayAsset())
                        .tag(audio as Audio?)
                }
            }
        })
        .onChange(of: selection, {
            if let audio = selection {
                if playMan.isPlaying {
                    playMan.play(audio.toPlayAsset(), reason: "点击了")
                } else {
                    playMan.prepare(audio.toPlayAsset())
                }
            }
        })
        .onChange(of: playMan.asset?.url, {
            selection = audios.first(where: {
                $0.url == playMan.asset?.url
            })
        })
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
