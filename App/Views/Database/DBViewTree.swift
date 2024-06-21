import OSLog
import SwiftData
import SwiftUI

struct DBViewTree: View {
    static var label = "📬 DBTree::"

    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var playManager: PlayManager
    @EnvironmentObject var db: DB

    @State var folderContents: [URL] = []
    @State var selection: String = ""
    @State var collapsed: Bool = true
    @State var deleting: Bool = false
    @State var icon: String = ""
    @State var rootURL: URL? = nil
    
    var playMan: PlayMan { playManager.playMan }
    
    var body: some View {
        if let rootURL = rootURL {
            DBTree(selection: $selection, folderURL: rootURL)
                .onChange(of: selection, {
                    playMan.play(.fromURL(URL(string: selection)!), reason: "点击了")
                })
        } else {
            LanuchView().task {
                self.rootURL = Config.disk.audiosDir
            }
        }
    }
}

#Preview {
    LayoutView(width: 400, height: 800)
        .frame(height: 800)
}
