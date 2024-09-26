import MagicKit
import OSLog
import SwiftData
import SwiftUI

struct AudioTitle: View, SuperLog, SuperThread {
    @EnvironmentObject var playMan: PlayMan

    @State var title: String = ""

    var width: CGFloat
    let emoji = "📺"

    var body: some View {
        ZStack {
            Text(title)
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
                .foregroundStyle(.white)
                .font(getFont(width: width))
        }
        .onAppear(perform: handleOnAppear)
        .onReceive(NotificationCenter.default.publisher(for: .PlayManStateChange), perform: handlePlayManStateChange)
    }

    /// 根据宽度来决定字体的大小
    func getFont(width: CGFloat) -> Font {
        let verbose = false
        guard title.isNotEmpty else {
            return .title
        }

        // 防止字较少时字体很大
        let characterCount = max(getCountCharacters(title), 5)

        if verbose {
            os_log("\(self.t)GetFont width -> \(width), characterCount=\(characterCount)")
        }

        return .system(size: max(width / CGFloat(characterCount) * 1.1, 20))
    }

    func getCountCharacters(_ input: String) -> Double {
        var count: Double = 0

        for char in input {
            if char.isASCII {
                count += 1
            } else {
                count += 2 // 其他字符算2个
            }
        }

        return count
    }
}

// MARK: Event Handler

extension AudioTitle {
    func handleOnAppear() {
        self.title = playMan.asset?.title ?? ""
    }

    func handlePlayManStateChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo, let state = userInfo["state"] as? PlayState else {
            return
        }

        withAnimation {
            self.title = playMan.asset?.title ?? ""
        }
    }
}

#Preview("APP") {
    BootView {
        ContentView()
    }.modelContainer(Config.getContainer)
}

#Preview("Layout") {
    LayoutView()
}

#Preview("Layout-350") {
    LayoutView(width: 350)
}

#Preview("iPhone 15") {
    LayoutView(device: .iPhone_15)
}

#Preview("iPad") {
    LayoutView(device: .iPad_mini)
}

#Preview("iMac") {
    LayoutView(device: .iMac)
}
