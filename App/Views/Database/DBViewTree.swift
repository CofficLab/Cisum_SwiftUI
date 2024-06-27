import OSLog
import SwiftData
import SwiftUI

struct DBViewTree: View {
    static var label = "📬 DBTreeView::"

    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var playMan: PlayMan

    @State var selection: DiskFile?
    @State var collapsed: Bool = false
    @State var icon: String = ""

    var disk: Disk { dataManager.disk }
    var root: URL { disk.root }

    var body: some View {
        DBTree(
            selection: $selection,
            icon: $icon,
            collapsed: collapsed,
            file: disk.getRoot()
        )
        .onAppear {
            self.icon = dataManager.isiCloudDisk ? "icloud" : "folder"
        }
        .onChange(of: selection, {
            if let s = selection, s.isNotFolder() {
                if playMan.isPlaying {
                    playMan.play(s.toPlayAsset(), reason: "点击了")
                } else {
                    playMan.prepare(s.toPlayAsset())
                }
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
        .frame(height: 820)
}
