import SwiftUI

struct CardView<Content, Background>: View where Content: View, Background: View {
    private let content: Content
    private var background: Background
    private var paddingVertical: CGFloat = 8

    init(background: Background, paddingVertical: CGFloat? = nil, @ViewBuilder content: () -> Content) {
        self.background = background
        self.content = content()
        self.paddingVertical = paddingVertical ?? self.paddingVertical
    }

    var body: some View {
        content
            .padding(.horizontal, 16)
            .padding(.vertical, paddingVertical)
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
