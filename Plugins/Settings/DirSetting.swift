import SwiftUI
import MagicKit

struct DirSetting: View {
    @EnvironmentObject var dataManager: DataProvider
    
    @State var diskSize: String?

    var mountedURL: URL? {
        dataManager.disk.getMountedURL()
    }

    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text("仓库目录").font(.headline)
                    Spacer()
                    if let diskSize = diskSize {
                        Text(diskSize)
                    }
                    if let url = mountedURL, Config.isDesktop {
                        BtnOpenFolder(url: url)
                            .labelStyle(.iconOnly)
                    }
                }
                .task {
                    if let disk = dataManager.disk.make("", verbose: true) {
                        diskSize = disk.getFileSizeReadable()
                    }
                }
                
                VStack(alignment: .leading) {
                    if dataManager.isiCloudDisk {
                        Text("是 iCloud 云盘目录，会保持同步")
                    } else {
                        Text("是本地目录，不会同步")
                    }
                }.font(.footnote)
            }.padding(10)
        }.background(BackgroundView.type1.opacity(0.1))
        
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
    BootView {
        SettingView()
            .background(.background)
    }.modelContainer(Config.getContainer)
        .frame(height: 1200)
}

#Preview {
    DirSetting()
}
