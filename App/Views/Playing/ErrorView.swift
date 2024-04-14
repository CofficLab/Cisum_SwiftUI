import Foundation
import SwiftUI
import SwiftData

struct ErrorView: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var audioManager: AudioManager
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \Audio.order, animation: .default) var audios: [Audio]

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
            EventManager().onUpdated({ items in
                for item in items {
                    if item.url == audioManager.audio?.url {
                        audioManager.checkError()
                        return
                    }
                }
            })
        }
        .onChange(of: count, {
            if audioManager.audio == nil, let first = db.getFirstValid() {
                audioManager.setCurrent(first, reason: "自动设置为第一首")
            }
            
            if count == 0 {
                audioManager.setCurrent(nil, reason: "数据库个数变成了0")
            }
            
            audioManager.checkError()
        })
    }
}

#Preview("APP") {
    RootView {
        ContentView()
    }.modelContainer(AppConfig.getContainer())
}

#Preview("Layout") {
    LayoutView()
}
