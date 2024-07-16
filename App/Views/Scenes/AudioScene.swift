import SwiftUI

struct AudioScene: View {
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
                    Image("DefaultAlbum")
                        .resizable()
                        .scaledToFit()
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

#Preview("Scenes") {
    BootView {
        Scenes(selection: Binding.constant(.Music), isPresented: .constant(false))
            .background(.background)
    }
    .frame(height: 800)
}
