import OSLog
import SwiftUI

struct BtnPrev: View {
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
      do {
        let message = try audioManager.prev(manual: true)
        os_log("\(Logger.isMain)BtnPrev::\(message)")
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
      BtnPrev()
    }
  })
}
