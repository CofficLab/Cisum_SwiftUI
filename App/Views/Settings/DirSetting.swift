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
                    if let url = mountedURL {
                        BtnOpenFolder(url: url)
                            .labelStyle(.iconOnly)
                    }
                }
                
                VStack(alignment: .leading) {
                    if dataManager.isiCloudDisk {
                        Text(dataManager.disk.getFileSizeReadable())
                        Text("☁️ 是 iCloud 云盘目录，会保持同步")
                    } else {
                        Text("💾 是本地目录，不会同步")
                    }
                }.font(.footnote)

                VStack(alignment: .leading) {
                    ForEach(DiskScene.allCases) { s in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(s.title)
                                if let disk = dataManager.disk.make(s.folderName) {
                                    Text(disk.getFileSizeReadable()).font(.footnote)
                                }
                            }
                            Spacer()
                            if let root = dataManager.disk.make(s.folderName)?.root {
                                BtnOpenFolder(url: root)
                            }
                        }
                    }
                }
                .labelStyle(.iconOnly)
                .padding(.leading)
            }.padding(10)
        }.background(BackgroundView.type1.opacity(0.1))
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
