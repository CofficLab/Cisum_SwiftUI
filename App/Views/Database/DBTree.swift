import OSLog
import SwiftData
import SwiftUI

struct DBTree: View {
    static var label = "📬 DBTree::"

    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var db: DB

    @State var folderContents: [URL] = []
    @Binding var selection: String
    @State var collapsed: Bool = true
    @State var deleting: Bool = false
    @State private var icon: String = ""

    var folderURL: URL
    
    var tree: DiskTree {
        DiskTree.fromURL(self.folderURL)
    }
    
    var asset: PlayAsset {
        tree.toPlayAsset()
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                MenuTile(
                    id: asset.url.absoluteString,
                    title: asset.title,
                    isFolder: asset.isFolder(), 
                    deleting: $deleting,
                    selectionId: $selection,
                    collapsed: $collapsed,
                    forceIcon: $icon
                )
                
                if let children = tree.children, !collapsed {
                    VStack(spacing: 0) {
                        ForEach(children, id: \.id) { node in
                            DBTree(selection: $selection,folderURL: node.url)
                        }
                    }
                }
            }
        }
    }
}

#Preview("DBTree") {
    RootView {
        DBTree(selection: Binding.constant(""), folderURL: DiskLocal().audiosDir)
            .background(.background)
            .padding()
    }
    .frame(height: 600)
}

#Preview {
    LayoutView(width: 400, height: 800)
        .frame(height: 800)
}
