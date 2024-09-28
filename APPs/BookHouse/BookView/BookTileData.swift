import MagicKit
import OSLog
import SwiftUI

/**
 展示从数据库读取的图书数据
 */
struct BookTileData: View {
    @EnvironmentObject var data: DataProvider
    @EnvironmentObject var playMan: PlayMan

    @State var state: BookState? = nil
    @State var scale: CGFloat = 1.0
    @State var opacity: Double = 1.0
    @State var cover: Image? = nil

    static var label = "🖥️ BookTileData::"

    var label: String { "\(Logger.isMain)\(Self.label)" }
    var hasCover: Bool { cover != nil }
    var noCover: Bool { cover == nil }

    var book: Book

    let mainQueue = DispatchQueue.main
    let backgroundQueue = DispatchQueue(label: "cisum.BookTileData", qos: .background)

    var body: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()

                if noCover {
                    Text(book.bookTitle).font(.title)
                }

                Spacer()

                if book.childCount > 0, noCover {
                    Text("共 \(book.childCount)")
                }

                Spacer()
                if let s = self.state, noCover, s.currentURL != nil {
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
        .background(getBackground())
        .foregroundStyle(.white)
        .scaleEffect(CGSize(width: scale, height: scale))
        .opacity(opacity)
        .onHover(perform: { hovering in
            withAnimation {
                scale = hovering ? 1.02 : 1
            }
        })
        .onTapGesture {
            withAnimation(.spring()) {
                if let s = self.state, let current = s.currentURL, let time = s.time {
                    playMan.play(PlayAsset(url: current), reason: "点击了书本")
                    playMan.goto(time)
                } else {
                    if let first = DiskFile(url: book.url).children?.first {
                        playMan.play(first.toPlayAsset(), reason: "点击了书本")
//                        data.updateBookState(book.url, first.url)
                    } else {
                        playMan.play(book.toPlayAsset(), reason: "点击了书本")
                    }
                }

                scale = 0.95
                opacity = 0.95

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.spring()) {
                        scale = 1.0
                        opacity = 1.0
                    }
                }
            }
        }
        .task {
            updateCover()

            if self.state == nil {
                findState()
            }
        }
        // .onChange(of: playMan.url, {
        //     findState()
        // })
//        .onChange(of: data.updating, {
//                data.updating.urls.forEach { url in
//                    if url.relativeString.hasPrefix(self.book.url.relativeString) {
//                        updateCover()
//                    }
//                }
//            })
        .contextMenu(menuItems: {
            BtnShowInFinder(url: book.url, autoResize: false)
        })
    }

    func getBackground() -> some View {
        ZStack {
            if let cover = cover {
                cover.resizable().scaledToFit()
            } else {
                BackgroundView.type2A
            }
        }
        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)))
        .shadow(radius: 5)
    }

    func findState(verbose: Bool = false) {
//        backgroundQueue.async {
//            if verbose {
//                os_log("\(label)FindState for \(book.title)")
//            }
//
//            if let state = data.findBookState(book) {
//                mainQueue.async {
//                    self.state = state
//                }
//            } else {
//                if verbose {
//                    os_log("\(label)\(book.title) 无上次播放")
//                }
//            }
//        }
    }

    func updateCover() {
        backgroundQueue.async {
            if self.cover == nil {
                Task {
                    self.cover = await book.getBookCover()
                }
            }
        }
    }
}

#Preview {
    AppPreview()
        .frame(height: 800)
}
