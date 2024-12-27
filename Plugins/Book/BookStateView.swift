import MagicKit
import MagicUI
import OSLog
import SwiftData
import SwiftUI

struct BookStateView: View, SuperLog, SuperThread {
    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var messageManager: MessageProvider
    @EnvironmentObject var bookManager: BookProvider
    @EnvironmentObject var playMan: PlayMan
    @EnvironmentObject var db: BookRecordDB
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \CopyTask.createdAt, animation: .default) var tasks: [CopyTask]

    var taskCount: Int { tasks.count }
    var showCopyMessage: Bool { tasks.count > 0 }
    var asset: PlayAsset? { playMan.asset }
    var font: Font { asset == nil ? .title3 : .callout }
    static let emoji = "🖥️"
    let verbose = true

    var body: some View {
        VStack {
            if messageManager.stateMessage.count > 0 {
                makeInfoView(messageManager.stateMessage)
            }

            // 播放过程中出现的错误
            if let e = playMan.error {
                makeErrorView(e)
            }
        }
        .onChange(of: bookManager.isSyncing, {
            os_log("\(self.t)isSyncing: \(bookManager.isSyncing)")
            
//            if playMan.hasError, let asset = playMan.asset, asset.isDownloaded {
//                playMan.play(verbose: true)
//            }
        })
    }

    func makeInfoView(_ i: String) -> some View {
        MagicCard(background: MagicBackground.aurora, paddingVertical: 6) {
            HStack {
                Image(systemName: "info.circle")
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
                Image(systemName: "info.circle")
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
