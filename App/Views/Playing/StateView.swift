import SwiftData
import SwiftUI

struct StateView: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var audioManager: AudioManager
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Audio.order, animation: .default) var audios: [Audio]

    @State private var next: Audio?

    var showState = false
    var totalStorage: String { iCloudHelper.getTotalStorageReadable() }
    var availableStorage: String { iCloudHelper.getAvailableStorageReadable() }
    var audio: Audio? { audioManager.audio }
    var db: DB { audioManager.db }
    var count: Int { audios.count }
    var hasError: Bool {audioManager.playerError != nil}
    var font: Font {
        if audio == nil {
            return .title3
        }

        return .callout
    }

    var body: some View {
        VStack {
            if showState || hasError {
                Spacer()
            }
            
            if showState {
                stateView
            }
            
            if hasError {
                errorView
            }
            
            if showState || hasError {
                Spacer()
            }
        }
    }
    
    var stateView: some View {
        ZStack {
            if let audio = audio {
                HStack(spacing: 2) {
                    if let n = next {
                        Text("下一首：\(n.title)")
                    } else {
                        Text("无下一首")
                    }

                    Text("共 \(totalStorage)")
                    Text("余 \(availableStorage)")
                }
                .onAppear {
                    Task {
                        self.next = await audioManager.db.nextOf(audio)
                        iCloudHelper.checkiCloudStorage1()
                    }
                }
                .onChange(of: audio) {
                    Task {
                        self.next = await audioManager.db.nextOf(audio)
                    }
                }
            }
        }
    }

    var errorView: some View {
        VStack {
            // 播放过程中出现的错误
            if let e = audioManager.playerError {
                CardView(background: BackgroundView.type3, paddingVertical: 6) {
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
        .onAppear {
            EventManager().onUpdated { items in
                for item in items {
                    if item.url == audioManager.audio?.url {
                        audioManager.checkError()
                        return
                    }
                }
            }
        }
        .onChange(of: count) {
            if audioManager.audio == nil, let first = db.getFirstValid() {
                audioManager.setCurrent(first, reason: "自动设置为第一首")
            }

            if count == 0 {
                audioManager.setCurrent(nil, reason: "数据库个数变成了0")
            }

            audioManager.checkError()
        }
    }
}

#Preview("APP") {
    AppPreview()
}
