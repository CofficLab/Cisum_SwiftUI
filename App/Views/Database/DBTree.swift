import OSLog
import SwiftData
import SwiftUI

struct DBTree: View {
    static var label = "📬 DBTree::"

    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var diskManager: DiskManager
    @EnvironmentObject var db: DB
    
    @Binding var selection: DiskFile?
    @State var collapsed: Bool = true
    @State var deleting: Bool = false
    @State var icon: String = ""
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
                
                if let children = children, !collapsed {
                    VStack(spacing: 0) {
                        ForEach(children, id: \.id) { child in
                            DBTree(
                                selection: $selection,
                                level: level + 1, file: child
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
        DBTree(selection: Binding.constant(DiskFile.home), file: DiskLocal().getRoot())
            .background(.background)
            .padding()
    }
    .frame(height: 600)
}

#Preview("DBTree-iCloud") {
    RootView {
        DBTree(selection: Binding.constant(DiskFile.home), file: DiskiCloud().getRoot())
            .background(.background)
            .padding()
    }
    .frame(height: 600)
}

#Preview {
    LayoutView(width: 400, height: 800)
        .frame(height: 800)
}
