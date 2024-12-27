import SwiftUI
import MagicKit

struct AudioSettings: View, SuperSetting, SuperLog {
    static let emoji = "🔊"
    @EnvironmentObject var audioManager: AudioProvider
    
    @State var diskSize: String?

    var body: some View {
        makeSettingView(
            title: "\(Self.emoji) 歌曲仓库目录",
            content: {
                if audioManager.disk is CloudStorage {
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
                        BtnOpenFolder(url: audioManager.disk.getRoot().url)
                            .labelStyle(.iconOnly)
                    }
                }
            }
        )
        .task {
            diskSize = audioManager.disk.getFileSizeReadable()
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
