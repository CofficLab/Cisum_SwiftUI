import SwiftUI

struct DirScene: View {
    @State var diskSize: String?
//    
//    var scene: DiskScene

    var mountedURL: URL? {
        nil
//        dataManager.disk.getMountedURL()
    }

    var body: some View {
        EmptyView()
//        HStack {
//            scene.icon
//            Text(scene.title)
//            Spacer()
//            if let diskSize = diskSize {
//                Text(diskSize).font(.footnote)
//            }
//            if let root = dataManager.disk.make(scene.folderName)?.root, Config.isDesktop {
//                BtnOpenFolder(url: root)
//            }
//        }
//        .task {
//            if let disk = dataManager.disk.make(scene.folderName) {
//                self.diskSize = disk.getFileSizeReadable()
//            }
//        }
    }
}

#Preview("Setting") {
    RootView {
        SettingView()
            .background(.background)
    }
        .frame(height: 1200)
}
