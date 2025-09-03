import MagicCore
import SwiftUI

struct AudioPoster: View {
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
        VStack {
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
