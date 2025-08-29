import MagicCore
import OSLog
import SwiftUI

struct WelcomeView: View, SuperLog {
    nonisolated static let emoji = "🎉"

    var body: some View {
        os_log("\(self.t)开始渲染")
        return ZStack {
            LinearGradient(colors: [
                Color.indigo.opacity(0.85),
                Color.purple.opacity(0.85),
                Color.blue.opacity(0.85),
            ], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 48, weight: .semibold))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.white.opacity(0.95))
                        .shadow(color: .black.opacity(0.2), radius: 10, y: 8)

                    Text("美好即将开始")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .accessibilityAddTraits(.isHeader)

                    Text("准备好探索你的音乐世界")
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 8)

                StorageView()
                    .background(.background)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .strokeBorder(.white.opacity(0.15))
                    }
                    .shadow(color: .black.opacity(0.12), radius: 24, y: 12)

                Spacer(minLength: 0)
            }
            .padding(24)
        }
    }
}

#Preview("Welcome") {
    RootView {
        WelcomeView()
    }
    .frame(height: 800)
}

#if os(macOS)
#Preview("App - Large") {
    AppPreview()
        .frame(width: 600, height: 1000)
}

#Preview("App - Small") {
    AppPreview()
        .frame(width: 500, height: 800)
}
#endif

#if os(iOS)
#Preview("iPhone") {
    AppPreview()
}
#endif
