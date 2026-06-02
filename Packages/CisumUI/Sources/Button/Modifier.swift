import SwiftUI

/// 带禁用原因弹出框的修饰符
struct DisabledWithReasonModifier: ViewModifier {
    var isDisabled: Bool
    let reason: String
    @State private var showingPopover = false

    func body(content: Content) -> some View {
        content
            .disabled(isDisabled)
            .overlay {
                // overlay 始终存在（只要 isDisabled），避免因 showingPopover 变化导致重新创建
                if isDisabled {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            // 只在 popover 未显示时触发
                            guard !showingPopover else { return }
                            showingPopover = true
                        }
                }
            }
            .popover(isPresented: $showingPopover, arrowEdge: .top) {
                popoverContent
            }
    }

    private var popoverContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.orange)
                Text("无法执行此操作")
                    .font(.headline)
            }

            Divider()

            Text(reason)
                .font(.body)
        }
        .padding()
        .frame(width: 250, alignment: .leading)
    }
}

#if DEBUG
#Preview("Button Disabled with Reason") {
    DisabledWithReasonPreviews()
        .frame(width: 500, height: 700)
}
#endif
