import SwiftUI

struct ButtonNext: View {
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var appManager: AppManager

    @State private var hovered: Bool = false

    var body: some View {
        HStack {
            Label("下一曲", systemImage: "forward")
                .font(.system(size: 24))
        }
        .padding(8)
        .background(hovered ? Color.gray.opacity(0.4) : .clear)
        .clipShape(RoundedRectangle(cornerRadius: 8.0))
        .onTapGesture {
            audioManager.next({ message in
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
            ButtonNext()
        }
    })
}
