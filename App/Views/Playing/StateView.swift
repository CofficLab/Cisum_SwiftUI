import SwiftData
import SwiftUI

struct StateView: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var audioManager: AudioManager
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \CopyTask.createdAt, animation: .default) var tasks: [CopyTask]
    @Query(sort: \Audio.order, animation: .default) var audios: [Audio]

    var e = EventManager()
    var error: Error? { audioManager.error }
    var taskCount: Int { tasks.count }
    var showCopyMessage: Bool { tasks.count > 0 }
    var audio: Audio? { audioManager.audio }
    var db: DB { audioManager.db }
    var count: Int { audios.count }
    var font: Font {
        if audio == nil {
            return .title3
        }

        return .callout
    }

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
        }
        .onChange(of: count) {
            Task {
                if audioManager.audio == nil, let first = await db.first() {
                    audioManager.prepare(first, reason: "自动设置为第一首")
                }
            }

            if count == 0 {
                audioManager.prepare(nil, reason: "数据库个数变成了0")
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name.AudioUpdatedNotification), perform: { n in
            let data = n.userInfo as! [String: Audio]
            let audio = data["audio"]!

            if audio.url == audioManager.audio?.url, audio.isDownloaded {
                audioManager.prepare(audioManager.audio, reason: "StateView Detected Update")
            }
        })
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name.AudiosUpdatedNotification), perform: { notification in
            let data = notification.userInfo as! [String: [MetaWrapper]]
            let items = data["items"]!
            for item in items {
                if item.isDeleted {
                    continue
                }

                if item.url == audioManager.audio?.url {
                    if item.isDownloaded {
                        audioManager.prepare(audioManager.audio, reason: "StateView Detected Update")
                    }
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

#Preview("APP") {
    AppPreview()
}
