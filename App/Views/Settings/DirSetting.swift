import SwiftUI

struct DirSetting: View {
    @EnvironmentObject var dataManager: DataManager
    
    var mountedURL: URL? {
        dataManager.disk.getMountedURL()
    }

    var body: some View {
        GroupBox {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("仓库目录").font(.headline)
                    if dataManager.isiCloudDisk {
                        Text("☁️ 是 iCloud 云盘目录，会保持同步").font(.footnote)
                    } else {
                        Text("💾 是本地目录，不会同步").font(.footnote)
                    }
                }
                Spacer()
                
                if let url = mountedURL {
                    BtnOpenFolder(url: url)
                        .labelStyle(.iconOnly)
                }
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
