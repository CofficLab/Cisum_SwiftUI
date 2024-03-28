import SwiftUI

struct CardView<Content, Background>: View where Content: View, Background: View {
    private let content: Content
    private var background: Background

    init(background: Background, @ViewBuilder content: () -> Content) {
        self.background = background
        self.content = content()
    }

    var body: some View {
        content
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(background)
            .clipShape(
                RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    ZStack {
        BackgroundView()

        VStack {
            CardView(background: BackgroundView.type1) {
                Text("你好")
                    .foregroundColor(.white)
            }
            CardView(background: BackgroundView.type2) {
                Text("你好")
                    .foregroundColor(.white)
            }
            CardView(background: BackgroundView.type3) {
                Text("你好")
                    .foregroundColor(.white)
            }
            CardView(background: BackgroundView.type4) {
                Text("你好")
                    .foregroundColor(.white)
            }
        }.frame(width: 300, height: 300)
    }
}
