import OSLog
import SwiftData
import SwiftUI

struct TitleView: View {
    @EnvironmentObject var audioManager: PlayManager

    var asset: PlayAsset? { audioManager.asset }
    var characterCount: Int { asset?.title.count ?? 0 }
    var width: CGFloat
    var label: String {"\(Logger.isMain)📺 TitleView::"}
    var verbose = false

    @State var url: URL? = nil

    var body: some View {
        ZStack {
            if let asset = asset {
                Text(asset.title)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    .foregroundStyle(.white)
                    .font(getFont(width: width))
                // .background(AppConfig.makeBackground(.blue))
            }
        }
        .onAppear {
            if let audio = audioManager.asset {
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
//        .onChange(of: asset) {
//            self.url = asset?.url ?? nil
//        }
    }

    /// 根据宽度来决定字体的大小
    func getFont(width: CGFloat) -> Font {
        guard let audio = audioManager.asset else {
            return .title
        }

        // 防止字较少时字体很大
        let characterCount = max(getCountCharacters(audio.title), 5)

        if verbose {
            os_log("\(self.label)GetFont width -> \(width), characterCount=\(characterCount)")
        }

        return .system(size: max(width / CGFloat(characterCount) * 1.1, 20))
    }

    func getCountCharacters(_ input: String) -> Double {
        var count: Double = 0

        for char in input {
            if char.isASCII {
                count += 1
            } else {
                count += 2 // 其他字符算2个
            }
        }

        return count
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
