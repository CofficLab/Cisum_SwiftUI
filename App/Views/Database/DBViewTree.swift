import OSLog
import SwiftData
import SwiftUI

struct DBViewTree: View {
    static var label = "📬 DBTreeView::"

    @EnvironmentObject var playManager: PlayManager
    @EnvironmentObject var diskManager: DiskManager

    @State var selection: String = ""
    @State var collapsed: Bool = false
    @State var icon: String = ""

    var playMan: PlayMan { playManager.playMan }
    var disk: DiskContact { diskManager.disk }
    var root: URL { disk.audiosDir }

    var body: some View {
        DBTree(
            selection: $selection,
            collapsed: collapsed,
            file: disk.getRoot()
        )
        .onChange(of: selection, {
            playMan.play(.fromURL(URL(string: selection)!), reason: "点击了")
        })
    }
}

#Preview {
    LayoutView(width: 400, height: 800)
        .frame(height: 800)
}
