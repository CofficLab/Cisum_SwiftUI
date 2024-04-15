import SwiftUI

struct ButtonDismiss: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var appManager: AppManager

    @State private var hovered: Bool = false

    var body: some View {
        HStack {
            Label("完成", systemImage: "xmark.circle")
                .font(.system(size: 24))
                .foregroundStyle(.primary)
        }
        .padding(8)
        .background(hovered ? Color.gray.opacity(0.4) : .clear)
        .clipShape(RoundedRectangle(cornerRadius: 8.0))
        .onTapGesture {
            dismiss()
        }
        .onHover(perform: { hovering in
            withAnimation(.easeInOut) {
                hovered = hovering
            }
        })
    }
}

#Preview {
    ButtonDismiss()
}

#Preview("Layout") {
    LayoutView()
}
