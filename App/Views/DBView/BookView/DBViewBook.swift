import OSLog
import SwiftData
import SwiftUI

struct DBViewBook: View {
    static var label = "📬 DBList::"

    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var data: DataManager

    @State var selection: Audio? = nil
    @State var syncingTotal: Int = 0
    @State var syncingCurrent: Int = 0

    var disk: any Disk { data.disk }
    var root: URL { disk.root }
    var rootDiskFile: DiskFile { disk.getRoot() }
    var items: [DiskFile] { rootDiskFile.getChildren() ?? [] }
    var total: Int { items.count }
    var label: String { "\(Logger.isMain)\(Self.label)" }
    var showTips: Bool {
        if appManager.isDropping {
            return true
        }

        return appManager.flashMessage.isEmpty && total == 0
    }

    init(verbose: Bool = false) {
        if verbose {
            os_log("\(Logger.isMain)\(Self.label)初始化")
        }
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 150), spacing: 10),
            ], pinnedViews: [.sectionHeaders]) {
                ForEach(items) { item in
                    BookTile(file: item)
                        .frame(width: 150)
                        .frame(height: 200)
                }
            }
            .padding()
        }
    }
}

#Preview("App") {
    AppPreview()
        .frame(width: 800)
        .frame(height: 800)
}

#Preview {
    LayoutView(width: 400, height: 800)
        .frame(height: 800)
}
