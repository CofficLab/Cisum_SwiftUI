import SwiftUI

struct ButtonToggleDatabase: View {
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var appManager: AppManager

    @State private var hovered: Bool = false

    var body: some View {
        HStack {
            Label("仓库", systemImage: "music.note.list")
                .font(.system(size: 24))
        }
        .padding(8)
        .background(hovered ? Color.gray.opacity(0.4) : .clear)
        .clipShape(RoundedRectangle(cornerRadius: 8.0))
        .onTapGesture {
            appManager.showDatabase.toggle()
//            if appManager.showDatabase {
//                appManager.flashMessage = "展示数据库"
//            } else {
//                appManager.flashMessage = "隐藏数据库"
//            }
        }
        .onHover(perform: { hovering in
            withAnimation(.easeInOut) {
                hovered = hovering
            }
        })
    }
}
