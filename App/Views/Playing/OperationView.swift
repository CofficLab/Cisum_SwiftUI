import SwiftData
import SwiftUI

struct OperationView: View {
    @EnvironmentObject var audioManager: PlayManager
    @EnvironmentObject var db: DB
    
    @State var audio: Audio?

    var asset: PlayAsset? { audioManager.asset }
    var characterCount: Int { asset?.title.count ?? 0 }
    var geo: GeometryProxy

    var body: some View {
        HStack(spacing: 0, content: {
            Spacer()
            if let audio = audio {
                BtnLike(audio: audio, autoResize: true)
                if AppConfig.isDesktop {
                    BtnShowInFinder(url: audio.url, autoResize: true)
                }
                BtnDel(audios: [audio], autoResize: true)
            }
            Spacer()
        })
        .frame(maxWidth: .infinity)
        .foregroundStyle(.white)
        .labelStyle(.iconOnly)
        .onAppear {
            Task {
                if let asset = asset {
                    self.audio  = await db.findAudio(asset.url)
                }
            }
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
    }.modelContainer(AppConfig.getContainer)
}

#Preview("Layout") {
    LayoutView()
}
