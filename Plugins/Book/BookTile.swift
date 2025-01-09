import MagicKit
import MagicPlayMan
import MagicUI
import OSLog
import SwiftUI

/**
 展示从数据库读取的图书数据
 */
struct BookTile: View, SuperThread, @preconcurrency SuperLog {
    @EnvironmentObject var playMan: MagicPlayMan
    @EnvironmentObject var db: BookDB

    @State var state: BookState? = nil
    @State var scale: CGFloat = 1.0
    @State var opacity: Double = 1.0
    @State var cover: Image? = nil

    static let emoji = "🖥️"
    var hasCover: Bool { cover != nil }
    var noCover: Bool { cover == nil }
    var book: BookModel

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
            book.url.makeOpenButton()
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
                MagicBackground.deepForest
            }
        }
        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)))
        .shadow(radius: 5)
    }
}

// MARK: Action

extension BookTile {
    func updateCover() {
//        if self.cover == nil {
//            Task {
//                self.cover = await book.getBookCoverFromDB()
//            }
//        }
    }
}

// MARK: Event Handler

extension BookTile {
    func onAppear() {
        self.updateCover()
    }

    @MainActor
    func onHover(_ hovering: Bool) {
        withAnimation {
            scale = hovering ? 1.02 : 1
        }
    }

    @MainActor
    func onTap() {
        // 首先执行动画
        withAnimation(.spring()) {
            scale = 0.95
            opacity = 0.95
        }

        if let first = book.url.getChildren().first {
            playMan.play(url: first)
        } else {
            playMan.play(url: book.url)
        }

        // 延迟恢复动画
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { @MainActor in
            withAnimation(.spring()) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}

#Preview {
    AppPreview()
        .frame(height: 800)
}
