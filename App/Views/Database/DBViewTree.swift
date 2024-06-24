import OSLog
import SwiftData
import SwiftUI

struct DBViewTree: View {
    static var label = "📬 DBTreeView::"

    @EnvironmentObject var diskManager: DataManager
    @EnvironmentObject var playMan: PlayMan

    @State var selection: DiskFile?
    @State var collapsed: Bool = false
    @State var icon: String = ""

    var disk: Disk { diskManager.disk }
    var root: URL { disk.root }

    var body: some View {
        DBTree(
            selection: $selection,
            icon: $icon, 
            collapsed: collapsed, 
            file: disk.getRoot()
        )
        .onAppear {
            self.icon = diskManager.isiCloudDisk ? "icloud" : "folder"
        }
        .onChange(of: selection, {
            if let s = selection {
                playMan.play(s.toPlayAsset(), reason: "点击了")
            }
        })
        .onChange(of: playMan.asset?.url, {
            if let asset = playMan.asset {
                self.selection = DiskFile(url: asset.url)
            } else {
                self.selection = nil
            }
        })
    }
}

#Preview {
    LayoutView(width: 400, height: 800)
        .frame(height: 800)
}
