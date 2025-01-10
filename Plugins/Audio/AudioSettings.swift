import SwiftUI
import MagicKit


struct AudioSettings: View, SuperSetting, @preconcurrency SuperLog {
    static let emoji = "🔊"
    @EnvironmentObject var audioManager: AudioProvider
    
    @State var diskSize: String?

    var body: some View {
        makeSettingView(
            title: "\(Self.emoji) 歌曲仓库目录",
            content: {
                if audioManager.disk.isiCloud {
                    Text("是 iCloud 云盘目录，会保持同步")
                } else {
                    Text("是本地目录，不会同步")
                }
            },
            trailing: {
                HStack {
                    if let diskSize = diskSize {
                        Text(diskSize)
                    }
                    if Config.isDesktop {
                        audioManager.disk.makeOpenButton()
                    }
                }
            }
        )
        .task {
            diskSize = audioManager.disk.getSizeReadable()
        }
    }
}

#Preview("Setting") {
    RootView {
        SettingView()
            .background(.background)
    }
        .frame(height: 1200)
}
