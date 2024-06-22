import Network
import OSLog
import SwiftData
import SwiftUI

struct StateView: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var audioManager: PlayManager
    @EnvironmentObject var playMan: PlayMan
    @EnvironmentObject var db: DB
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \CopyTask.createdAt, animation: .default) var tasks: [CopyTask]
    @Query(sort: \Audio.order, animation: .default) var audios: [Audio]

    @State var networkOK = true

    var e = EventManager()
    var error: Error? { audioManager.error }
    var taskCount: Int { tasks.count }
    var showCopyMessage: Bool { tasks.count > 0 }
    var asset: PlayAsset? { playMan.asset }
    var count: Int { audios.count }
    var font: Font { asset == nil ? .title3 : .callout }
    var label: String { "\(Logger.isMain)🖥️ StateView::" }

    var body: some View {
        VStack {
            if appManager.stateMessage.count > 0 {
                makeInfoView(appManager.stateMessage)
            }

            // 播放过程中出现的错误
            if let e = error {
                makeErrorView(e)
            }

            // 正在复制
            if tasks.count > 0 {
                HStack {
                    makeCopyView("正在复制 \(tasks.count) 个文件")
                }.task {
                    try? await db.copyFiles()
                }
            }
        }
        .onAppear {
            if audios.count == 0 {
                appManager.showDBView()
            }

            checkNetworkStatus()
        }
        .onChange(of: count) {
            Task {
                if playMan.asset == nil, let first = await db.first() {
                    os_log("\(self.label)准备第一个")
                    playMan.prepare(first.toPlayAsset())
                }
            }

            if count == 0 {
                playMan.prepare(nil)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name.AudioUpdatedNotification), perform: { n in
            let data = n.userInfo as! [String: Audio]
            let audio = data["audio"]!

            if audio.url == playMan.asset?.url, audio.isDownloaded, playMan.isNotPlaying, playMan.currentTime == 0 {
                os_log("\(self.label)Audio更新后Prepare")
                playMan.prepare(playMan.asset)
            }
        })
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name.AudiosUpdatedNotification), perform: { notification in
            let data = notification.userInfo as! [String: DiskFileGroup]
            let items = data["items"]!
            for item in items.files {
                if item.isDeleted {
                    continue
                }

                if item.url == playMan.asset?.url, item.isDownloaded, playMan.isNotPlaying {
                    os_log("\(self.label)Audios更新后Prepare")
                    playMan.prepare(playMan.asset)
                }
            }
        })
    }

    func makeCopyView(_ i: String, buttons: some View = EmptyView()) -> some View {
        CardView(background: BackgroundView.type3, paddingVertical: 6) {
            HStack {
                Image(systemName: "info.circle")
                    .foregroundStyle(.white)
                Text(i)
                    .foregroundStyle(.white)
                BtnToggleDB()
                    .labelStyle(.iconOnly)
            }
            .font(font)
        }
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
        CardView(background: BackgroundView.type3, paddingVertical: 6) {
            HStack {
                Image(systemName: "info")
                    .foregroundStyle(.white)
                Text(e.localizedDescription)
                    .foregroundStyle(.white)
            }
            .font(font)
        }
    }
}

// MARK: 检查错误

extension StateView {
    func checkNetworkStatus() {
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                if path.status == .satisfied {
                    self.networkOK = true
                } else {
                    self.networkOK = false
                }
            }
        }

        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }
}

#Preview("APP") {
    AppPreview()
}
