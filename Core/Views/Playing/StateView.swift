import MagicCore

import OSLog
import SwiftData
import SwiftUI

struct StateView: View, SuperLog, SuperThread {
    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var messageManager: MessageProvider
    @EnvironmentObject var playMan: PlayMan

    var asset: URL? { playMan.asset }
    var font: Font { asset == nil ? .title3 : .callout }
    nonisolated static let emoji = "🖥️"
    let verbose = true

    var body: some View {
        VStack {
            if messageManager.stateMessage.count > 0 {
                makeInfoView(messageManager.stateMessage)
            }
            
            if playMan.isBuffering {
                makeInfoView(playMan.state.stateText)
            }

            // 播放过程中出现的错误
            if let e = playMan.currentError {
                makeErrorView(e)
            }
        }
    }

    func makeInfoView(_ i: String) -> some View {
        MagicCard(background: MagicBackground.aurora, paddingVertical: 6) {
            HStack {
                Image.info
                    .foregroundStyle(.white)
                Text(i)
                    .foregroundStyle(.white)
            }
            .font(font)
        }
    }

    func makeErrorView(_ e: Error) -> some View {
        MagicCard(background: MagicBackground.aurora, paddingVertical: 6) {
            HStack {
                Image.info
                    .foregroundStyle(.white)
                Text(e.localizedDescription)
                    .foregroundStyle(.white)
            }
            .font(font)
        }
    }
}

#Preview("APP") {
    AppPreview()
        .frame(height: 800)
}
