import MagicCore
import SwiftUI

struct AudioSettings: View, SuperSetting, SuperLog {
    nonisolated static let emoji = "🔊"
    @EnvironmentObject var audioManager: AudioProvider

    @State var diskSize: String?
    @State var description: String = ""

    var body: some View {
        MagicSettingSection {
            MagicSettingRow(title: "歌曲仓库", description: description, icon: .iconMusicLibrary, content: {
                HStack {
                    if let diskSize = diskSize {
                        Text(diskSize)
                    }
                    if Config.isDesktop {
                        audioManager.disk.makeOpenButton()
                    }
                }

            })
            .task {
                diskSize = audioManager.disk.getSizeReadable()
                if audioManager.disk.isiCloud {
                    description = "是 iCloud 云盘，会同步"
                } else {
                    description = "是本地目录，不会同步"
                }
            }
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
