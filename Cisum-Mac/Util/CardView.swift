import SwiftUI

struct CardView<Content>: View where Content: View {
    private let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.opacity(0.5))
                .shadow(radius: 2)
            
            content
        }
        .padding(.horizontal, 30)
        .frame(maxHeight: 100)
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            BackgroundView()
            
            CardView {
                Text("你好").foregroundColor(.white)
            }
        }
    }
}
