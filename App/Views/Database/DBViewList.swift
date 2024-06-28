import OSLog
import SwiftData
import SwiftUI

/*
 将仓库中的文件扁平化展示，文件夹将被忽略
    A
      A1               A1
      A2               A2
    B           =>     B1
      B1               B2
      B2
 */
struct DBViewList: View {
    static var label = "📬 DBList::"

    @EnvironmentObject var app: AppManager
    @EnvironmentObject var playMan: PlayMan
    @Environment(\.modelContext) private var modelContext

    @Query(Audio.descriptorAll, animation: .default) var audios: [Audio]

    @State var selection: Audio? = nil

    var total: Int { audios.count }
    var label: String { "\(Logger.isMain)\(Self.label)" }
    var items: [Audio] { audios.filter({ $0.isNotFolder()}) }

    init(verbose: Bool = false) {
        if verbose {
            os_log("\(Logger.isMain)\(Self.label)初始化")
        }
    }

    var body: some View {
        List(selection: $selection) {
            Section(header: HStack {
                Text("共 \(total.description)")
                Spacer()
                if Config.isNotDesktop {
                    BtnAdd()
                        .font(.title2)
                        .labelStyle(.iconOnly)
                }
            }, content: {
                ForEach(items, id: \.self) { audio in
                    DBRow(audio.toPlayAsset())
                        .tag(audio as Audio?)
                        .onTapGesture {
                            playMan.play(audio.toPlayAsset(), reason: "点击了")
                        }
                }
            })
        }
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
