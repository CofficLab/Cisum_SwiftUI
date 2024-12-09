import OSLog
import SwiftData
import SwiftUI

struct DBViewMenuTile: View {
    static var label = "📬 DBTreeView::"

    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var dataManager: DataProvider
    @EnvironmentObject var messageManager: MessageProvider
    @EnvironmentObject var playMan: PlayMan

    @State var selection: DiskFile?
    @State var collapsed: Bool = false
    @State var icon: String = ""

//    var disk: any SuperDisk { dataManager.disk }
//    var root: URL { disk.root }
//    var rootDiskFile: DiskFile { disk.getRoot() }
    
    var showTips: Bool {
        if app.isDropping {
            return true
        }
        return false

//        return messageManager.flashMessage.isEmpty && rootDiskFile.getChildren()?.isEmpty ?? true
    }

    var body: some View {
        ZStack {
//            DBTree(
//                selection: $selection,
//                icon: $icon,
//                collapsed: collapsed,
//                file: disk.getRoot()
//            )
//                .onAppear {
//                    self.icon = dataManager.isiCloudDisk ? "icloud" : "folder"
                }
//                .onChange(of: selection, {
//                    if let s = selection, s.isNotFolder() {
//                        try? playMan.play(s.toPlayAsset(), reason: "点击了", verbose: true)
//                    }
//                })
            //     .onChange(of: playMan.asset?.url, {
            //         if let asset = playMan.asset {
            //             self.selection = DiskFile(url: asset.url)
            //         } else {
            //             self.selection = nil
            //         }
            // }
//            )
            
            if showTips {
                DBTips()
            }
        }
    }
//}

#Preview("App") {
    AppPreview()
        .frame(height: 820)
}

#Preview {
    LayoutView(width: 400, height: 800)
        .frame(height: 820)
}
