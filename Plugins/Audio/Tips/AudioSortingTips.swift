import SwiftUI
import MagicCore

struct AudioSortingTips: View {
    let icon: String
    let description: String
    let isAnimating: Bool

    init(sortModeIcon: String, description: String, isAnimating: Bool) {
        self.icon = sortModeIcon
        self.description = description
        self.isAnimating = isAnimating
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundStyle(.tint)
                .rotationEffect(.degrees(360))
                .animation(.linear(duration: 2).repeatForever(autoreverses: false), value: isAnimating)

            Text(description)
                .font(.headline)
                .foregroundStyle(.secondary)
                .padding(.top, 24)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Preview

#if os(macOS)
#Preview("App - Large") {
    AppPreview()
        .overlay {
            AudioSortingTips(sortModeIcon: "shuffle", description: "正在排序...", isAnimating: true)
        }
        .frame(width: 600, height: 1000)
}

#Preview("App - Small") {
    AppPreview()
        .overlay {
            AudioSortingTips(sortModeIcon: "arrow.triangle.2.circlepath", description: "正在排序...", isAnimating: true)
        }
        .frame(width: 600, height: 600)
}
#endif

#if os(iOS)
#Preview("iPhone") {
    AppPreview()
        .overlay {
            AudioSortingTips(sortModeIcon: "shuffle", description: "正在排序...", isAnimating: true)
        }
}
#endif


