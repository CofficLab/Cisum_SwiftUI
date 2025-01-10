import MagicKit

import OSLog
import SwiftData
import SwiftUI

struct TitleView: View, @preconcurrency SuperLog, SuperThread {
    @EnvironmentObject var playMan: PlayMan

    var title: String { playMan.asset?.title ?? "" }
    static let emoji = "📺"

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Text(title)
                    .font(.system(size: 24))
                    .lineLimit(2)
                    .minimumScaleFactor(0.3)
                    .multilineTextAlignment(.center)
                    .frame(width: geo.size.width - 32)
                    .frame(maxHeight: .infinity)
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)
                    .padding(.vertical)
            }
        }
        .background(Config.background(.red))
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
