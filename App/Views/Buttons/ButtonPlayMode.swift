import SwiftUI

struct ButtonPlayMode: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var audioManager: AudioManager

    @State private var hovered: Bool = false

    var body: some View {
        HStack {
            Label("模式", systemImage: getImageName())
                .font(.system(size: 24))
        }
        .padding(8)
        .background(hovered ? Color.gray.opacity(0.4) : .clear)
        .clipShape(RoundedRectangle(cornerRadius: 8.0))
        .onTapGesture {
            audioManager.playlist.switchPlayMode({ mode in
                appManager.setFlashMessage("\(mode.description)")
            })
        }
        .onHover(perform: { hovering in
            withAnimation(.easeInOut) {
                hovered = hovering
            }
        })
    }

    private func getImageName() -> String {
        switch audioManager.playlist.playMode {
        case .Order:
            return "repeat"
        case .Loop:
            return "repeat.1"
        case .Random:
            return "shuffle"
        }
    }
}

#Preview {
    RootView {
        Centered {
            ButtonPlayMode()
        }
    }
}
