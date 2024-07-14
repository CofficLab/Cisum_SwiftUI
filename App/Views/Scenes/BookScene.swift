import SwiftUI

struct BookScene: View {
    var books: [String] = [
        "三国演义",
        "西游记",
        "红楼梦",
        "水浒传",
    ]

    var body: some View {
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
                .background(BackgroundView.forest)
                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)))
                .frame(width: 130)
                .frame(height: 180)
            }
        }
        .padding()
    }
}

#Preview("Scenes") {
    BootView {
        Scenes(selection: Binding.constant(.AudiosBook), isPreseted: Binding.constant(false))
            .background(.background)
    }
    .frame(height: 800)
}
