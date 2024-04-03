import SwiftUI
import OSLog

struct TableDemo: View {
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var appManager: AppManager
    
    @State private var selections = Set<Audio.ID>()
    @State private var sortOrder = [KeyPathComparator(\Audio.title)]
        
    var body: some View {
            Table(
                of: Audio.self, selection: $selections, sortOrder: $sortOrder,
                columns: {
                    // value 参数用于排序
                    TableColumn("", value: \.title,
                                content: { audio in
                        print("🐛 DBTableView::Refresh DBFirstCol")
                        return Text("A--")
                    })
                }, rows: getRows)
    }
    
    private func getRows() -> some TableRowContent<Audio> {
        print("🐛 DBTableView::getRows")
        return ForEach([Audio(AppConfig.coverDir, db: DB())]) { audio in
            TableRow(audio)
        }
    }
    
    init() {
         print("\(Logger.isMain)🚩 DBTableView::Init")
    }
}

#Preview {
    RootView {
        TableDemo()
    }
}
