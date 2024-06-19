import OSLog
import SwiftData
import SwiftUI

struct DBTree: View {
    static var label = "📬 DBTree::"

    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var db: DB

    @State var folderContents: [URL] = []
    @State var selection: DiskTree.ID?

    var folderURL: URL

    init(folderURL: URL, verbose: Bool = false) {
        self.folderURL = folderURL

        if verbose {
            os_log("\(Logger.isMain)\(Self.label)初始化")
        }
    }
    
    var body: some View {
        List([DiskTree.fromURL(folderURL)], children: \.children, selection: $selection) { item in
            DBRow(Audio(item.url))
        }
    }
}

#Preview {
    LayoutView(width: 400, height: 800)
        .frame(height: 800)
}
