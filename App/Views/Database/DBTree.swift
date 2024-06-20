import OSLog
import SwiftData
import SwiftUI

struct DBTree: View {
    static var label = "📬 DBTree::"

    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var db: DB

    @State var folderContents: [URL] = []
    @State var selection: DiskTree.ID?
    @State var selected: Bool = false
    @State var collapsed: Bool = true
    @State var deleting: Bool = false
    @State private var icon: String = ""

    var folderURL: URL
    var tree: DiskTree
    
    var asset: PlayAsset {
        tree.toPlayAsset()
    }

    init(folderURL: URL, verbose: Bool = false) {
        if verbose {
            os_log("\(Logger.isMain)\(Self.label)初始化")
        }
        
        self.folderURL = folderURL
        self.tree = DiskTree.fromURL(self.folderURL)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                MenuTile(
                    title: asset.title,
                    isFolder: asset.isFolder(), 
                    deleting: $deleting,
                    selected: $selected,
                    collapsed: $collapsed,
                    forceIcon: $icon
                )
                
                if let children = tree.children, !collapsed {
                    VStack(spacing: 0) {
                        ForEach(children, id: \.id) { node in
                            DBTree(folderURL: node.url)
                        }
                    }
                }
            }
        }
    }
}

#Preview("DBTree") {
    RootView {
        DBTree(folderURL: DiskLocal().audiosDir)
            .background(.background)
            .padding()
    }
    .frame(height: 600)
}

#Preview {
    LayoutView(width: 400, height: 800)
        .frame(height: 800)
}
