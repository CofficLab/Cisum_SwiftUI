import MagicCore
import SwiftUI

struct AudioSettings: View, SuperLog {
    nonisolated static let emoji = "🔊"

    @State var diskSize: String?
    @State var description: String = ""
    @State var fileCount: Int = 0

    var body: some View {
        if let disk = AudioPlugin.getAudioDisk() {
            MagicSettingSection(title: "歌曲仓库") {
                MagicSettingRow(title: "仓库大小", description: description, icon: .iconMusicLibrary, content: {
                    HStack {
                        if let diskSize = diskSize {
                            Text(diskSize)
                                .font(.footnote)
                        }
                    }

                })
                .task {
                    diskSize = disk.getSizeReadable()
                    if disk.isiCloud {
                        description = "是 iCloud 云盘，会同步"
                    } else {
                        description = "是本地目录，不会同步"
                    }
                }

                #if os(macOS)
                    MagicSettingRow(title: "打开仓库", description: "在Finder中查看", icon: .iconShowInFinder, content: {
                        HStack {
                            disk.makeOpenButton()
                                .magicSize(.small)
                        }

                    })
                #endif

                MagicSettingRow(title: "文件数量", description: "当前仓库内的文件总数", icon: .iconDocument, content: {
                    HStack {
                        Text("\(fileCount) 个文件")
                            .font(.footnote)
                    }
                })
                .task {
                    self.fileCount = disk.filesCountRecursively()
                }
            }
        } else {
            MagicSettingSection(title: "歌曲仓库") {
                MagicSettingRow(title: "出现错误", description: description, icon: .iconMusicLibrary, content: {
                    Text("暂时不能获取歌曲仓库信息")
                        .font(.footnote)

                })
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
