import OSLog
import SwiftData
import SwiftUI

struct DBViewBookData: View {
    static var label = "📬 DBList::"

    @EnvironmentObject var appManager: AppProvider
    @EnvironmentObject var data: DataProvider

    @State var selection: Audio? = nil
    @State var syncingTotal: Int = 0
    @State var syncingCurrent: Int = 0
    
    @Query(Book.descriptorIsFolder) var books: [Book]

    var total: Int { books.count }
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
                ForEach(books) { item in
                    BookTileData(book: item)
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
