import SwiftUI
import MagicCore
import MagicBackground

/// 有声书海报视图，展示示例书目。
struct BookPoster: View {
    var books: [String] = [
        "巴黎圣母院",
        "海底两万里",
        "三国演义",
        "西游记",
        "红楼梦",
        "水浒传",
    ]

    var body: some View {
        hstackView
    }

    var hstackView: some View {
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

