import SwiftUI
import SwiftData

/**
 展示从数据库读取的图书数据
 */
struct BookTileData: View {
    @EnvironmentObject var playMan: PlayMan
    @EnvironmentObject var db: DBSynced
    @Environment(\.modelContext) var modelContext
    
    @Query(Book.descriptorAll) var books: [Book]
    
    @State var state: BookState? = nil
    
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
                if let s = self.state {
                    Text("上次播放 \(s.currentTitle)").padding()
                }
            }
            Spacer()
        }
        .background(BackgroundView.type2A)
        .foregroundStyle(.white)
        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)))
        .onTapGesture {
            playMan.play(book.toPlayAsset(), reason: "点击了书本")
        }
        .onAppear {
            Task {
                if let state = await db.find(self.book.url) {
                    DispatchQueue.main.async {
                        self.state = state
                    }
                }
            }
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
