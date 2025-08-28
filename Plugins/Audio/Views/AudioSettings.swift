import MagicCore
import SwiftUI

struct AudioSettings: View, SuperLog {
    nonisolated static let emoji = "🔊"
    @EnvironmentObject var audioManager: AudioProvider

    @State var diskSize: String?
    @State var description: String = ""

    var body: some View {
        MagicSettingSection(title: "歌曲仓库") {
            MagicSettingRow(title: "仓库大小", description: description, icon: .iconMusicLibrary, content: {
                HStack {
                    if let diskSize = diskSize {
                        Text(diskSize)
                            .font(.footnote)
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

            MagicSettingRow(title: "文件数量", description: "当前仓库内的文件总数", icon: .iconDocument, content: {
                HStack {
                    Text("\(audioManager.disk.filesCountRecursively()) 个文件")
                        .font(.footnote)
                }
            })
            .task {
                // 这里假设 getFileCount() 是同步方法，如果是异步请调整
            }
        }
    }
}

#Preview("Setting") {
    RootView {
        SettingView()
            .background(.background)
    }
    .frame(height: 800)
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
