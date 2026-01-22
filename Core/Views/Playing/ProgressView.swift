import MagicKit
import SwiftUI

struct PlayingProgressView: View {
    @Environment(\.demoMode) var isDemoMode
    @EnvironmentObject var playMan: PlayMan

    var body: some View {
        if isDemoMode {
            demoProgressView
        } else {
            playMan.makeProgressView()
        }
    }

    // MARK: 演示模式的进度条

    private var demoProgressView: some View {
        VStack(alignment: .center, spacing: 8) {
            // 进度条
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // 背景条
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.secondary.opacity(0.2))

                    // 进度
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.blue)
                        .frame(width: geometry.size.width * 0.35)
                }
            }
            .frame(height: 4)

            // 时间标签
            HStack {
                Text("1:24")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)

                Spacer()

                Text("3:45")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#if os(macOS)
    #Preview("App - Large") {
        ContentView()
            .inRootView()
            .frame(width: 600, height: 1000)
    }

    #Preview("App - Small") {
        ContentView()
            .inRootView()
            .frame(width: 500, height: 600)
    }

    #Preview("App Store Hero") {
        AppStoreHero()
            .inMagicContainer(.macBook13, scale: 1)
    }
#endif

#if os(iOS)
    #Preview("iPhone") {
        ContentView()
            .inRootView()
    }
#endif
