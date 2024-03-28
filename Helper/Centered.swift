import SwiftUI

struct Centered<Content>: View where Content: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    content
                    Spacer()
                }
                Spacer()
            }
        }
    }
}

#Preview {
    ZStack {
        BackgroundView()

        VStack {
            Spacer()
            Centered {
                Text("你好").foregroundColor(.white)
            }
            Spacer()
        }.frame(width: 300, height: 300)
    }
}
