import SwiftUI
import MagicCore
import MagicBackground

/// 有声书海报视图，展示示例书目。
struct BookPoster: View {
    @EnvironmentObject private var pluginProvider: PluginProvider
    @EnvironmentObject private var m: MagicMessageProvider

    var books: [String] = [
        "巴黎圣母院",
        "海底两万里",
        "三国演义",
        "西游记",
        "红楼梦",
        "水浒传",
        "三体",
        "百年孤独",
        "追风筝的人",
        "白夜行",
        "挪威的森林",
    ]

    var body: some View {
        VStack(spacing: 16) {
            hStackView

            MagicButton.simple(action: {
                do {
                    try pluginProvider.setCurrentGroup(id: BookPlugin().id)
                } catch {
                    m.error(error)
                }
            })
            .magicShape(.roundedRectangle)
            .magicSize(.auto)
            .magicTitle("进入有声书仓库")
            .magicIcon(.iconArrowUpCircle)
            .frame(width: 130)
            .frame(height: 40)
        }
    }

    var hStackView: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(books, id: \.self) { item in
                    HStack {
                        Spacer()
                        VStack {
                            Spacer()
                            ForEach(Array(item.enumerated()), id: \.offset) { _, character in
                                Text(String(character))
                                    .padding(1)
                                    .foregroundColor(.white)
                            }
                            Spacer()
                        }
                        Spacer()
                    }
                    .background(MagicBackground.aurora)
                    .clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)))
                    .frame(width: 50)
                    .frame(height: 200)
                }
            }
        }
    }

    var gridView: some View {
        LazyVGrid(columns: [
            GridItem(.adaptive(minimum: 120), spacing: 15),
        ], pinnedViews: [.sectionHeaders]) {
            ForEach(books, id: \.self) { item in
                HStack {
                    Spacer()
                    VStack {
                        Spacer()
                        Text(item)
                        Spacer()
                    }
                    Spacer()
                }
                .background(MagicBackground.deepOceanCurrent)
                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)))
                .frame(width: 130)
                .frame(height: 180)
            }
        }
        .padding()
    }
}

#Preview("Poster") {
    BookPoster()
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
        .frame(width: 600, height: 600)
}
#endif

#if os(iOS)
#Preview("iPhone") {
    AppPreview()
}
#endif
