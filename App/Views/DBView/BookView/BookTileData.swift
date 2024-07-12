import OSLog
import SwiftData
import SwiftUI

/**
 展示从数据库读取的图书数据
 */
struct BookTileData: View {
    @EnvironmentObject var data: DataManager
    @EnvironmentObject var playMan: PlayMan
    @Environment(\.modelContext) var modelContext

    @Query(Book.descriptorAll) var books: [Book]

    @State var state: BookState? = nil
    @State var scale: CGFloat = 1.0
    @State var opacity: Double = 1.0
    @State var chapterCount: Int? = nil

    static var label = "🖥️ BookTileData::"

    var label: String { "\(Logger.isMain)\(Self.label)" }

    var book: Book

    let mainQueue = DispatchQueue.main
    let backgroundQueue = DispatchQueue(label: "cisum.BookTileData", qos: .background)

    var body: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                Text(book.title).font(.title)
                Spacer()
                
                if let c = chapterCount {
                    Text("共 \(c)")
                }
                
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
        .scaleEffect(CGSize(width: scale, height: scale))
        .opacity(opacity)
        .onTapGesture {
            withAnimation(.spring()) {
                if let s = self.state, let current = s.currentURL, let time = s.time {
                    playMan.play(PlayAsset(url: current), reason: "点击了书本")
                    playMan.goto(time)
                } else {
                    if let first = DiskFile(url: book.url).children?.first {
                        playMan.play(first.toPlayAsset(), reason: "点击了书本")
                        data.updateBookState(book.url, first.url)
                    } else {
                        playMan.play(book.toPlayAsset(), reason: "点击了书本")
                    }
                }

                scale = 0.95
                opacity = 0.8
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.spring()) {
                        scale = 1.0
                        opacity = 1.0
                    }
                }
            }
        }
        .task {
            if self.state == nil {
                findState()
            }
            
            if self.chapterCount == nil {
                getChapterCount()
            }
        }
        .onChange(of: playMan.url, {
            findState()
        })
        .contextMenu(menuItems: {
            BtnShowInFinder(url: book.url, autoResize: false)
        })
    }
    
    func getChapterCount() {
        backgroundQueue.async {
            let chapterCount = books.filter({
                $0.url.absoluteString.hasPrefix(self.book.url.absoluteString)
            }).count
            
            mainQueue.async {
                self.chapterCount = chapterCount
            }
        }
    }

    func findState(verbose: Bool = false) {
        backgroundQueue.async {
            if verbose {
                os_log("\(label)FindState for \(book.title)")
            }

            if let state = data.findBookState(book) {
                mainQueue.async {
                    self.state = state
                }
            } else {
                if verbose {
                    os_log("\(label)\(book.title) 无上次播放")
                }
            }
        }
    }
}

#Preview {
    AppPreview()
        .frame(height: 800)
}
