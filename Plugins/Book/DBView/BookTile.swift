import MagicKit
import OSLog
import SwiftUI

/**
 展示从数据库读取的图书数据
 */
struct BookTile: View, SuperThread, SuperLog {
    @EnvironmentObject var data: DataProvider
    @EnvironmentObject var playMan: PlayMan
    
    @State var state: BookState? = nil
    @State var scale: CGFloat = 1.0
    @State var opacity: Double = 1.0
    @State var cover: Image? = nil
    
    let emoji = "🖥️"
    var hasCover: Bool { cover != nil }
    var noCover: Bool { cover == nil }
    var book: Book
    
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
        .contextMenu(menuItems: {
            BtnShowInFinder(url: book.url, autoResize: false)
        })
        .onHover(perform: onHover)
        .onAppear(perform: onAppear)
        .onTapGesture(perform: onTap)
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
}

// MARK: Action

extension BookTile {
    func updateCover() {
        if self.cover == nil {
            Task {
                self.cover = await book.getBookCoverFromDB()
            }
        }
    }
}

// MARK: Event Handler

extension BookTile {
    func onAppear() {
        self.updateCover()
    }
    
    func onHover(_ hovering: Bool) {
        withAnimation {
            scale = hovering ? 1.02 : 1
        }
    }
    
    func onTap() {
        withAnimation(.spring()) {
            if let s = self.state, let current = s.currentURL, let time = s.time {
                playMan.play(PlayAsset(url: current), reason: "点击了书本",verbose: true)
                playMan.seek(time)
            } else {
                if let first = DiskFile(url: book.url).children?.first {
                    playMan.play(first.toPlayAsset(), reason: "点击了书本", verbose: true)
                    //                        data.updateBookState(book.url, first.url)
                } else {
                    playMan.play(book.toPlayAsset(), reason: "点击了书本", verbose: true)
                }
            }
            
            scale = 0.95
            opacity = 0.95
            
            self.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.spring()) {
                    scale = 1.0
                    opacity = 1.0
                }
            }
        }
    }
}

#Preview {
    AppPreview()
        .frame(height: 800)
}
