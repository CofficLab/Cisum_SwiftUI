import SwiftData
import SwiftUI

struct TitleView: View {
    @EnvironmentObject var audioManager: AudioManager

    var audio: Audio? { audioManager.audio }
    var characterCount: Int { audio?.title.count ?? 0 }
    var geo: GeometryProxy

    @State var url: URL? = nil

    var body: some View {
        ZStack {
            if let audio = audio {
                Text(audio.title)
                    .foregroundStyle(.white)
                    .font(getFont())
                // .background(AppConfig.makeBackground(.blue))
            }
        }
        .onAppear {
            if let audio = audioManager.audio {
                self.url = audio.url
            }

            // 监听到了事件，注意要考虑audio已经被删除了的情况
            EventManager().onUpdated { items in
                for item in items {
                    if item.isDeleted && item.url == self.url {
                        audioManager.audio = nil
                        continue
                    }
                }
            }
        }
        .onChange(of: audio) {
            self.url = audio?.url ?? nil
        }
    }

    func getFont() -> Font {
        if geo.size.height < 100 {
            return .title3
        }

        if geo.size.height < 200 {
            return .title2
        }

        return .title
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
