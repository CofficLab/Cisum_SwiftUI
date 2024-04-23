import SwiftData
import SwiftUI

struct TitleView: View {
    @EnvironmentObject var audioManager: AudioManager

    var audio: Audio? { audioManager.audio }
    var characterCount: Int { audio?.title.count ?? 0 }

    @State var url: URL? = nil

    var body: some View {
        ZStack {
            GeometryReader { geo in
                if let audio = audio {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text(audio.title)
                                .multilineTextAlignment(.leading)
                                .lineLimit(nil)
                                .foregroundStyle(.white)
                                .font(getFont(width: geo.size.width))
                            // .background(AppConfig.makeBackground(.blue))
                            Spacer()
                        }
                        Spacer()
                    }
                }
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

    func getFont(width: CGFloat) -> Font {
        guard let audio = audioManager.audio else {
            return .title
        }

        return .system(size: max(width / CGFloat(audio.title.count), 20))
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
