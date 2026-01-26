import MagicKit
import SwiftUI

struct ResetProgressContent: View {
    var body: some View {
        SheetContainer {
            VStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(.quaternary)
                        .frame(width: 60, height: 60)
                    Image(systemName: .iconReset)
                        .symbolRenderingMode(.hierarchical)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(.tint)
                }

                Text("正在重置…")
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            .padding(.bottom, 8)
            .background(.background.opacity(0.4))
            .roundedMedium()
            .shadowSm()
        }
    }
}

// MARK: - Preview

#Preview("ResetConfirmContent") {
    ResetConfirmContent(onCancel: {}, onConfirm: {})
        .frame(width: 400)
        .inRootView()
}

#Preview("ResetProgressContent", traits: .sizeThatFitsLayout) {
    ResetProgressContent()
        .padding()
}

#Preview("ResetConfirmContent - Dark") {
    ResetConfirmContent(onCancel: {}, onConfirm: {})
        .padding()
        .frame(width: 400)
        .inRootView()
        .preferredColorScheme(.dark)
}

#Preview("ResetProgressContent - Dark", traits: .sizeThatFitsLayout) {
    ResetProgressContent()
        .padding()
        .preferredColorScheme(.dark)
}

#if os(macOS)
    #Preview("App - Large") {
        ContentView()
            .inRootView()
            .frame(width: 600, height: 1000)
    }

    #Preview("App - Small") {
        ContentView()
            .inRootView()
            .frame(width: 600, height: 600)
    }
#endif

#if os(iOS)
    #Preview("iPhone") {
        ContentView()
            .inRootView()
    }
#endif
