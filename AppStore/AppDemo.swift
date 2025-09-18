import SwiftUI

/// 简化的 App 演示视图
struct AppDemo: View {
    var body: some View {
        Text("App Demo")
            .font(.largeTitle)
            .foregroundColor(.primary)
    }
}

// MARK: - Preview

#if os(macOS)
#Preview("App - Large") {
    AppDemo()
        .frame(width: 600, height: 1000)
}

#Preview("App - Small") {
    AppDemo()
        .frame(width: 600, height: 600)
}
#endif

#if os(iOS)
#Preview("iPhone") {
    AppDemo()
}
#endif

