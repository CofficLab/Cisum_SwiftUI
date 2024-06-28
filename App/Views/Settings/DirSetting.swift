import SwiftUI

struct DirSetting: View {
    @EnvironmentObject var dataManager: DataManager

    var mountedURL: URL? {
        dataManager.disk.getMountedURL()
    }

    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text("仓库目录").font(.headline)
                    Spacer()
                    if let disk = dataManager.disk.make("") {
                        Text(disk.getFileSizeReadable())
                    }
                    if let url = mountedURL, Config.isDesktop {
                        BtnOpenFolder(url: url)
                            .labelStyle(.iconOnly)
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
        
        GroupBox {
            VStack {
                ForEach(Array(DiskScene.allCases.enumerated()), id: \.offset) { (index, s) in
                    HStack {
                        s.icon
                        Text(s.title)
                        Spacer()
                        if let disk = dataManager.disk.make(s.folderName) {
                            Text(disk.getFileSizeReadable()).font(.footnote)
                        }
                        if let root = dataManager.disk.make(s.folderName)?.root, Config.isDesktop {
                            BtnOpenFolder(url: root)
                        }
                    }

                    // 如果不是最后一个元素,才显示分割线
                    if index < DiskScene.allCases.count - 1 {
                        Divider()
                    }
                }
            }
            .padding(10)
        }
        .labelStyle(.iconOnly)
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
