import SwiftUI

/// Cisum 演示视图 - 模拟实际运行时的界面
struct AppDemo: View {
    @State private var progress: Double = 0.35

    var body: some View {
        ContentView()
            .inRootView()
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
