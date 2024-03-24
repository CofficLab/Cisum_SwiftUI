import SwiftUI

struct ButtonShowDatabase: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var appManager: AppManager

    @State private var hovered: Bool = false

    var body: some View {
        HStack {
            Label("仓库", systemImage: "tray.full.fill")
                .font(.system(size: 24))
                .foregroundStyle(.primary)
        }
        .padding(8)
        .background(hovered ? Color.gray.opacity(0.4) : .clear)
        .clipShape(RoundedRectangle(cornerRadius: 8.0))
        .onTapGesture {
            appManager.showDB = true
        }
        .onHover(perform: { hovering in
            withAnimation(.easeInOut) {
                hovered = hovering
            }
        })
    }
}

#Preview {
    ButtonShowDatabase()
}
