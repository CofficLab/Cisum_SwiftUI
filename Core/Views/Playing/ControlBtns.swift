import MagicKit
import OSLog
import SwiftUI

struct ControlBtns: View, SuperLog {
    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var message: StateProvider
    @EnvironmentObject var man: PlayMan
    @Environment(\.demoMode) var isDemoMode

    nonisolated static let emoji = "🎵"
    static let verbose = false

    var body: some View {
        HStack {
            Spacer(minLength: 50)

            if isDemoMode {
                demoButtonsView
            } else {
                BtnToggleDB()
                man.makePreviousButtonView(size: .auto)
                man.makePlayPauseButtonView(size: .auto)
                man.makeNextButtonView(size: .auto)
                man.makePlayModeButtonView(size: .auto)
            }

            Spacer(minLength: 50)
        }
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: 演示模式的按钮

    private var demoButtonsView: some View {
        HStack(spacing: 4) {
            // ToggleDB 按钮
            Button(action: {}) {
                Image.more
                    .font(.system(size: 24))
                    .foregroundColor(.secondary)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .shadowSm()

            // 上一曲按钮
            Button(action: {}) {
                Image(systemName: "backward.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.secondary)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .shadowSm()

            // 播放/暂停按钮
            Button(action: {}) {
                Image.pauseFill
                    .font(.system(size: 32))
                    .foregroundColor(.blue)
                    .frame(width: 56, height: 56)
            }
            .buttonStyle(.plain)
            .shadowSm()

            // 下一曲按钮
            Button(action: {}) {
                Image(systemName: "forward.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.secondary)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .shadowSm()

            // 播放模式按钮
            Button(action: {}) {
                Image(systemName: "repeat")
                    .font(.system(size: 20))
                    .foregroundColor(.secondary)
                    .frame(width: 40, height: 40)
            }
            .buttonStyle(.plain)
            .shadowSm()
        }
    }
}

// MARK: - Preview

#if os(macOS)
    #Preview("App - Large") {
        ContentView()
            .inRootView()
            .frame(width: 600, height: 1000)
    }

    #Preview("App - Small") {
        ContentView()
            .inRootView()
            .frame(width: 500, height: 800)
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
