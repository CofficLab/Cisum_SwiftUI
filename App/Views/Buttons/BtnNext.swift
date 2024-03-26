import SwiftUI
import OSLog

struct BtnNext: View {
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
            do {
                let message = try audioManager.next(manual: true)
                os_log("BtnNext::\(message)")
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
            BtnNext()
        }
    })
}
