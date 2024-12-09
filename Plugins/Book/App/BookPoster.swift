import SwiftUI
import MagicKit

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
                    .background(BackgroundView.type2A)
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
                .background(BackgroundView.type2A)
                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)))
                .frame(width: 130)
                .frame(height: 180)
            }
        }
        .padding()
    }
}
