import SwiftUI

struct ButtonPrev: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var audioManager: AudioManager
    
    @State private var hovered: Bool = false
    
    var body: some View {
        HStack {
            Label("上一曲", systemImage: "backward")
                    .font(.system(size: 24))
        }
        .padding(8)
        .background(hovered ? Color.gray.opacity(0.4) : .clear)
        .clipShape(RoundedRectangle(cornerRadius: 8.0))
        .onTapGesture {
            audioManager.prev({ message in
                appManager.setFlashMessage(message)
            })
        }
        .onHover(perform: { hovering in
            withAnimation(.easeInOut) {
                hovered = hovering
            }
        })
    }
}

#Preview {
    RootView(content: {
        Centered {
            ButtonPrev()
        }
    })
}

