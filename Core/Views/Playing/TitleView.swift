import MagicCore

import OSLog
import SwiftData
import SwiftUI

struct TitleView: View, SuperLog, SuperThread {
    @EnvironmentObject var playMan: PlayMan

    var title: String { playMan.asset?.deletingPathExtension().title ?? "" }
    nonisolated static let emoji = "📺"

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

#Preview("App - Large") {
    AppPreview()
        .frame(width: 600, height: 1000)
}

#Preview("App - Small") {
    AppPreview()
        .frame(width: 500, height: 800)
}

#if os(iOS)
#Preview("iPhone") {
    AppPreview()
}
#endif

