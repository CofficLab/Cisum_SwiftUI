import SwiftUI

struct SmartContainer<Content>: View where Content: View {
    private var content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack{
            content
        }
        .frame(minWidth: 100, minHeight: 100)
        .background(BackgroundView.type1)
    }
}

#Preview {
    SmartContainer(content: {
        Text("hello")
    })
}
