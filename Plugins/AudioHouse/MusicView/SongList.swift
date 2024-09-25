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
struct SongList: View {
    static var label = "📬 DBList::"

    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var data: DataProvider
    @EnvironmentObject var playMan: PlayMan
    @Environment(\.modelContext) var modelContext

    @Query(Audio.descriptorNotFolder) var audios: [Audio]

    @State var selection: Audio? = nil

    var total: Int { audios.count }
    var label: String { "\(Logger.isMain)\(Self.label)" }

    var showTips: Bool {
        if app.isDropping {
            return true
        }

        return app.flashMessage.isEmpty && audios.count == 0
    }

    init(verbose: Bool = false) {
        if verbose {
            os_log("\(Logger.isMain)\(Self.label)初始化")
        }
    }

    var body: some View {
        ZStack {
            List(selection: $selection) {
                Section(header: HStack {
                    Text("共 \(total.description)")
                    Spacer()
                    if data.syncing {
                        HStack {
                            Image(systemName: "arrow.triangle.2.circlepath")
                            Text("正在读取仓库")
                        }
                    }
                    if Config.isNotDesktop {
                        BtnAdd()
                            .font(.title2)
                            .labelStyle(.iconOnly)
                    }
                }, content: {
                    ForEach(audios, id: \.self) { audio in
                        SongTile(audio.toPlayAsset())
                            .tag(audio as Audio?)
                    }
                })
            }
            .onChange(of: playMan.asset, {
                setSelection()
            })
            .onAppear {
                setSelection()
            }

            if showTips {
                DBTips()
            }
        }
    }
    
    func setSelection() {
        selection = audios.first(where: {
            $0.url == playMan.asset?.url
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
