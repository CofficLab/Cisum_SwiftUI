import OSLog
import SwiftData
import SwiftUI
import MagicKit
import MagicUI

struct BookGrid: View, SuperLog, SuperThread {
    static let emoji = "📖"

    @EnvironmentObject var appManager: AppProvider
    @EnvironmentObject var messageManager: MessageProvider
    @EnvironmentObject var db: BookDB

    @State var selection: AudioModel? = nil
    @State var syncingTotal: Int = 0
    @State var syncingCurrent: Int = 0
    @State var books: [Book] = []
    
    var total: Int { books.count }
    var showTips: Bool {
        if appManager.isDropping {
            return true
        }

        return messageManager.flashMessage.isEmpty && total == 0
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 150), spacing: 10),
            ], pinnedViews: [.sectionHeaders]) {
                ForEach(books) { item in
                    BookTile(book: item)
                        .frame(width: 150)
                        .frame(height: 200)
                }
            }
            .padding()
        }
        .onAppear(perform: handleOnAppear)
    }
    
    func handleOnAppear() {
        Task {
            self.books = await db.getRootBooks()
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
