import SwiftUI
import MagicKit

struct AudioSettings: View, SuperSetting, SuperLog {
    static let emoji = "🔊"
    @EnvironmentObject var dataManager: DataProvider
    @EnvironmentObject var audioManager: AudioProvider
    
    @State var diskSize: String?

    var body: some View {
        makeSettingView(
            title: "\(Self.emoji) 歌曲仓库目录",
            content: {
                if audioManager.disk is DiskiCloud {
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
        
        // 注释掉的 GroupBox 保持不变
//        GroupBox {
//            VStack {
//                ForEach(Array(DiskScene.allCases.filter({
//                    $0.available
//                }).enumerated()), id: \.offset) { (index, s) in
//                    DirScene(scene: s)
//
//                    // 如果不是最后一个元素,才显示分割线
//                    if index < DiskScene.allCases.count - 1 {
//                        Divider()
//                    }
//                }
//            }
//            .padding(10)
//        }
//        .labelStyle(.iconOnly)
    }
}

#Preview("Setting") {
    RootView {
        SettingView()
            .background(.background)
    }
        .frame(height: 1200)
}
