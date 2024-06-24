import OSLog
import SwiftData
import SwiftUI

struct DBTree: View {
    static var label = "📬 DBTree::"

    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var diskManager: DataManager
    
    @Binding var selection: DiskFile?
    @Binding var icon: String
    @State var collapsed: Bool = true
    @State var deleting: Bool = false
    @State var children: [DiskFile]?

    var level: Int = 0
    var file: DiskFile
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                MenuTile(
                    id: file,
                    title: file.title,
                    isFolder: file.isFolder(),
                    level: level,
                    deleting: $deleting,
                    selectionId: $selection,
                    collapsed: $collapsed,
                    forceIcon: $icon
                )
                .onAppear {
                    self.children = file.getChildren()
                    file.onChange {
                        self.children = file.getChildren()
                    }
                }
                .onChange(of: file, {
                    self.children = file.getChildren()
                })
                .contextMenu(menuItems: {
                    BtnPlay(asset: file.toPlayAsset(), autoResize: false)
                    Divider()
                    BtnDownload(asset: file.toPlayAsset())
                    BtnEvict(asset: file.toPlayAsset())
                    if Config.isDesktop {
                        BtnShowInFinder(url: file.url, autoResize: false)
                    }
                    Divider()
                    BtnDel(assets: [file.toPlayAsset()], autoResize: false)
                })
                
                if let children = children, !collapsed {
                    VStack(spacing: 0) {
                        ForEach(children, id: \.id) { child in
                            DBTree(
                                selection: $selection,
                                icon: Binding.constant(""), 
                                level: level + 1,
                                file: child
                            )
                        }
                    }
                }
            }
        }
    }
}

#Preview("DBTree-Local") {
    RootView {
        DBTree(
            selection: Binding.constant(DiskFile.home),
            icon: Binding.constant(""),
            file: DiskLocal().getRoot()
        )
        .background(.background)
        .padding()
    }
    .frame(height: 600)
}

#Preview("DBTree-iCloud") {
    RootView {
        DBTree(
            selection: Binding.constant(DiskFile.home),
            icon: Binding.constant(""), 
            file: DiskiCloud().getRoot()
        )
        .background(.background)
        .padding()
    }
    .frame(height: 600)
}

#Preview {
    LayoutView(width: 400, height: 800)
        .frame(height: 800)
}
