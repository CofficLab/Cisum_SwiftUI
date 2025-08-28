import MagicCore
import SwiftUI

struct AudioSettings: View, SuperLog {
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
                        audioManager.disk
                            .makeOpenButton()
                            .magicSize(.small)
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

#if os(macOS)
    #Preview("App - Large") {
        AppPreview()
            .frame(width: 600, height: 1000)
    }

    #Preview("App - Small") {
        AppPreview()
            .frame(width: 600, height: 600)
    }
#endif

#if os(iOS)
    #Preview("iPhone") {
        AppPreview()
    }
#endif
