import SwiftUI
import SwiftData

struct BookTileData: View {
    @EnvironmentObject var playMan: PlayMan
    @EnvironmentObject var db: DB
    @Environment(\.modelContext) var modelContext
    
    @Query(Book.descriptorAll) var books: [Book]
    
    var chapters: [Book] {
        books.filter({
            $0.url.absoluteString.hasPrefix(self.book.url.absoluteString)
        })
    }
    
    var book: Book
    
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                Text(book.title).font(.title)
                Spacer()
                Text("共 \(chapters.count)")
                Spacer()
            }
            Spacer()
        }
        .background(BackgroundView.type2A)
        .foregroundStyle(.white)
        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)))
        .onTapGesture {
            playMan.play(book.toPlayAsset(), reason: "点击了书本")
        }
        .contextMenu(menuItems: {
            BtnShowInFinder(url: book.url, autoResize: false)
        })
    }
}

#Preview {
    AppPreview()
        .frame(height: 800)
}
