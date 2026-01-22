import MagicKit
import MagicPlayMan
import OSLog
import SwiftData
import SwiftUI

struct StateView: View, SuperLog, SuperThread {
    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var messageManager: StateProvider
    @EnvironmentObject var playMan: PlayMan
    @Environment(\.demoMode) var isDemoMode

    nonisolated static let emoji = "🖥️"
    nonisolated static let verbose = false

    var asset: URL? { playMan.asset }
    var font: Font { asset == nil ? .title3 : .callout }

    var body: some View {
        if isDemoMode {
            EmptyView()
        } else {
            VStack {
                if messageManager.stateMessage.count > 0 {
                    makeInfoView(messageManager.stateMessage)
                }

                if playMan.state.isDownloading {
                    makeInfoView(playMan.state.localizedStateText(localization: playMan.localization))
                }

                // 播放过程中出现的错误
                if let e = playMan.currentError {
                    makeErrorView(e)
                }
            }
        }
    }
}

// MARK: - View

extension StateView {
    func makeInfoView(_ i: String) -> some View {
        HStack {
            Image.info
                .foregroundStyle(.white)
            Text(i)
                .foregroundStyle(.white)
        }
        .font(font)
        .inCard()
    }

    func makeErrorView(_ e: Error) -> some View {
        HStack {
            Image.info
                .foregroundStyle(.white)
            // 如果是 PlaybackError，使用本地化描述
            if let playbackError = e as? PlaybackState.PlaybackError {
                Text(playbackError.localizedDescription(localization: playMan.localization))
                    .foregroundStyle(.white)
            } else {
                Text(e.localizedDescription)
                    .foregroundStyle(.white)
            }
        }
        .font(font)
        .inCard()
    }
}

// MARK: - Action

extension StateView {
}

// MARK: - Setter

extension StateView {
}

// MARK: - Event Handler

extension StateView {
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

    #Preview("Demo Mode") {
        ContentView()
            .inRootView()
            .inDemoMode()
            .frame(width: 500, height: 800)
    }
#endif

#if os(iOS)
    #Preview("iPhone") {
        ContentView()
            .inRootView()
    }
#endif
