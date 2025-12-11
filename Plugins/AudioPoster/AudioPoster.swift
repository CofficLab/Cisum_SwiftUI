import MagicCore
import SwiftUI

/// 音频海报视图，展示示例曲目列表。
struct AudioPoster: View {
    @EnvironmentObject private var pluginProvider: PluginProvider
    @EnvironmentObject private var m: MagicMessageProvider

    var books: [String] = [
        "挪威的森林",
        "歌唱祖国",
        "让我们荡起双桨",
        "遇见",
        "青花瓷",
        "伤心太平洋",
        "一千个伤心的理由",
    ]

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 0) {
                ForEach(books, id: \.self) { item in
                    HStack {
                        Image.musicNote
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .padding(8)
                            .background(
                                Circle()
                                    .fill(Color.blue.opacity(0.15))
                            )
                        Text(item)
                        Spacer()
                    }
                    .frame(height: 30)
                    Divider()
                }
            }
            
            MagicButton.simple(action: {
                do {
                    try pluginProvider.setCurrentGroup(id: AudioPlugin().id)
                } catch {
                    m.error(error)
                }
            })
            .magicShape(.roundedRectangle)
            .magicSize(.auto)
            .magicTitle("进入音乐仓库")
            .magicIcon(.iconArrowUpCircle)
            .frame(width: 120)
            .frame(height: 40)
        }
        .padding()
    }
}

#Preview("Poster") {
    AudioPoster()
        .frame(width: 600)
        .frame(height: 600)
}

#if os(macOS)
    #Preview("App - Large") {
        AppPreview()
            .frame(width: 600, height: 1000)
    }

    #Preview("App - Small") {
        AppPreview()
            .frame(width: 500, height: 800)
    }
#endif

#if os(iOS)
    #Preview("iPhone") {
        AppPreview()
    }
#endif

