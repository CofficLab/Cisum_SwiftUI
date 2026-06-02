import SwiftUI

public struct VDemoSection<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(icon)
                Text(title)
                    .font(.headline)
                    .bold()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                content
            }
            .padding(.leading, 20)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
