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
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    .foregroundStyle(.white)
                    .font(getFont())
                // .background(AppConfig.makeBackground(.blue))
            }
        }
        .onAppear {
            if let audio = audioManager.audio {
                self.url = audio.url
            }

            EventManager().onDelete { items in
                for item in items {
                    if item.isDeleted && item.url == self.url {
                        AppConfig.mainQueue.async {
                            audioManager.prepare(nil, reason: "TitleView")
                            audioManager.player.stop()
                        }
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

        return .system(size: geo.size.height/18)
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

#Preview("Layout-350") {
    LayoutView(width: 350)
}

#Preview("iPhone 15") {
    LayoutView(device: .iPhone_15)
}

#Preview("iPad") {
    LayoutView(device: .iPad_mini)
}

#Preview("iMac") {
    LayoutView(device: .iMac)
}
