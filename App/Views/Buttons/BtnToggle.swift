import SwiftUI
import OSLog

struct BtnToggle: View {
    var play: Bool? = true
    
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var appManager: AppManager
    @State private var hovered: Bool = false

    var body: some View {
        HStack {
            if !audioManager.isPlaying {
                Label("播放", systemImage: "play.fill")
                    .font(.system(size: 40))
            } else {
                Label("暂停", systemImage: "pause.fill")
                    .font(.system(size: 40))
            }
        }
        // 固定宽度，防止因为图标不一样宽而改变宽度
        .frame(width: 40, height: 40)
        .padding(10)
        .background(hovered ? Color.gray.opacity(0.4) : .clear)
        .clipShape(RoundedRectangle(cornerRadius: 8.0))
        .onTapGesture {
            do {
                let message = try audioManager.togglePlayPause()
                os_log("🖥️ BtnToggle::\(message)")
            } catch let e {
                appManager.setFlashMessage(e.localizedDescription)
            }
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
            BtnToggle()
        }
        
        ControlView()
    })
}
