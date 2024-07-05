import OSLog
import SwiftData
import SwiftUI

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

    var label: String { "\(Logger.isMain)🖥️ BookTileData::" }

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
                    VStack(spacing: 0) {
                        HStack {
                            Image(systemName: "info")
                            Text("上次播放")
                        }
                        Text(s.currentTitle)
                    }
                    .font(.footnote)
                    .padding()
                }
            }
            Spacer()
        }
        .background(BackgroundView.type2A)
        .foregroundStyle(.white)
        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)))
        .onTapGesture {
            if let s = self.state, let current = s.currentURL, let time = s.time {
                playMan.play(PlayAsset(url: current), reason: "点击了书本")
                playMan.goto(time)
            } else {
                playMan.play(book.toPlayAsset(), reason: "点击了书本")
            }
        }
        .onAppear {
            findState()
        }
        .onChange(of: playMan.state.getAsset()?.url, {
            findState()
        })
        .contextMenu(menuItems: {
            BtnShowInFinder(url: book.url, autoResize: false)
        })
    }

    func findState() {
        Task {
            os_log("\(self.label)FindState for \(self.book.title)")
            if let state = await db.findBookState(self.book.url) {
                DispatchQueue.main.async {
                    self.state = state
                }
            } else {
                os_log("\(self.label)\(self.book.title) 无上次播放")
            }
        }
    }
}

#Preview {
    AppPreview()
        .frame(height: 800)
}
