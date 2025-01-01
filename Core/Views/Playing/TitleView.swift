import MagicKit
import MagicUI
import OSLog
import SwiftData
import SwiftUI

struct TitleView: View, SuperLog, SuperThread {
    @EnvironmentObject var playMan: MagicPlayMan

    var title: String { playMan.asset?.title ?? "" }
    var width: CGFloat
    static let emoji = "📺"

    var body: some View {
        ZStack {
            Text(playMan.asset?.title ?? "")
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
                .foregroundStyle(.white)
                .font(getFont(width: width))
        }
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

#Preview("APP") {
    RootView {
        ContentView()
    }
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
