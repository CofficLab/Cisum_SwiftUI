import SwiftUI

struct DirScene: View {
    @EnvironmentObject var dataManager: DataManager
    
    @State var diskSize: String?
    
    var scene: DiskScene

    var mountedURL: URL? {
        dataManager.disk.getMountedURL()
    }

    var body: some View {
        HStack {
            scene.icon
            Text(scene.title)
            Spacer()
            if let diskSize = diskSize {
                Text(diskSize).font(.footnote)
            }
            if let root = dataManager.disk.make(scene.folderName)?.root, Config.isDesktop {
                BtnOpenFolder(url: root)
            }
        }
        .task {
            if let disk = dataManager.disk.make(scene.folderName) {
                self.diskSize = disk.getFileSizeReadable()
            }
        }
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
