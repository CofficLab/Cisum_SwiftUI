import MagicKit
import OSLog
import SwiftData
import SwiftUI

struct AudioStateView: View, SuperLog, SuperThread {
    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var data: DataProvider
    @EnvironmentObject var messageManager: MessageProvider
    @EnvironmentObject var audioManager: AudioProvider
    @EnvironmentObject var playMan: PlayMan
    @EnvironmentObject var db: RecordDB
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \CopyTask.createdAt, animation: .default) var tasks: [CopyTask]

    var taskCount: Int { tasks.count }
    var showCopyMessage: Bool { tasks.count > 0 }
    var asset: PlayAsset? { playMan.asset }
    var font: Font { asset == nil ? .title3 : .callout }
    let emoji = "🖥️"
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

            // 正在复制
            if tasks.count > 0 && app.showDB == false {
                StateCopy()
            }
        }
        .onChange(of: audioManager.isSyncing, {
            os_log("\(self.t)isSyncing: \(audioManager.isSyncing)")
            
            if playMan.hasError, let asset = playMan.asset, asset.isDownloaded {
                playMan.play(verbose: true)
            }
        })
    }

    func makeInfoView(_ i: String) -> some View {
        CardView(background: BackgroundView.type3, paddingVertical: 6) {
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
        CardView(background: BackgroundView.type5, paddingVertical: 6) {
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
