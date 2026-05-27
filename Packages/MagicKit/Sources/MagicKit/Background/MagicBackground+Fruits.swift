import SwiftUI

extension MagicBackground {
    public static var watermelon: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "FF6B6B").opacity(0.7), // 西瓜红
                    Color(hex: "F0FFF0").opacity(0.6), // 淡绿色
                ]),
                startPoint: .top,
                endPoint: .bottom
            )

            // 简化的西瓜籽效果
            GeometryReader { geometry in
                VStack(spacing: geometry.size.height * 0.1) {
                    HStack(spacing: geometry.size.width * 0.1) {
                        ForEach(0 ..< 5) { _ in
                            Circle()
                                .fill(Color.black.opacity(0.1))
                                .frame(width: 8, height: 8)
                        }
                    }
                    HStack(spacing: geometry.size.width * 0.1) {
                        ForEach(0 ..< 4) { _ in
                            Circle()
                                .fill(Color.black.opacity(0.1))
                                .frame(width: 8, height: 8)
                        }
                    }
                }
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }

    public static var orange: some View {
        ZStack {
            RadialGradient(
                gradient: Gradient(colors: [
                    Color(hex: "FFA500").opacity(0.7), // 橙色
                    Color(hex: "FF8C00").opacity(0.6), // 深橙色
                ]),
                center: .center,
                startRadius: 100,
                endRadius: 400
            )

            // 简化的橙子纹理
            GeometryReader { geometry in
                Path { path in
                    path.move(to: CGPoint(x: geometry.size.width / 2, y: 0))
                    path.addLine(to: CGPoint(x: geometry.size.width / 2, y: geometry.size.height))
                    path.move(to: CGPoint(x: 0, y: geometry.size.height / 2))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height / 2))
                }
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
            }
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }

    public static var blueberry: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "4B0082").opacity(0.6), // 靛蓝色
                    Color(hex: "6A5ACD").opacity(0.5), // 石板蓝
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // 简化的果霜效果
            Circle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 200)
                .blur(radius: 50)
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }

    public static var strawberry: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "FF4D4D").opacity(0.7), // 鲜红色
                    Color(hex: "FF1A1A").opacity(0.6), // 深红色
                ]),
                startPoint: .top,
                endPoint: .bottom
            )

            // 简化的草莓籽效果
            VStack(spacing: 20) {
                ForEach(0 ..< 3) { _ in
                    HStack(spacing: 20) {
                        ForEach(0 ..< 3) { _ in
                            Circle()
                                .fill(Color(hex: "FFEB3B").opacity(0.2))
                                .frame(width: 6, height: 6)
                        }
                    }
                }
            }
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }

    public static var kiwi: some View {
        ZStack {
            Color(hex: "90EE90").opacity(0.6) // 淡绿色

            // 简化的猕猴桃纹理
            Circle()
                .strokeBorder(Color(hex: "556B2F").opacity(0.2), lineWidth: 2)
                .frame(width: 200)

            // 简化的籽粒效果
            VStack(spacing: 15) {
                ForEach(0 ..< 3) { _ in
                    HStack(spacing: 15) {
                        ForEach(0 ..< 3) { _ in
                            Circle()
                                .fill(Color.black.opacity(0.2))
                                .frame(width: 4, height: 4)
                        }
                    }
                }
            }
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
}

#if DEBUG
#Preview("Fruit Themes") {
    TabView {
        // 水果主题
        ScrollView {
            VStack(spacing: 20) {
                Text("水果主题")
                    .font(.headline)
                    .padding(.top)

                Group {
                    BackgroundPreviewItem(
                        background: AnyView(MagicBackground.watermelon),
                        title: "Watermelon",
                        textColor: .primary
                    )

                    BackgroundPreviewItem(
                        background: AnyView(MagicBackground.orange),
                        title: "Orange",
                        textColor: .primary
                    )

                    BackgroundPreviewItem(
                        background: AnyView(MagicBackground.blueberry),
                        title: "Blueberry"
                    )

                    BackgroundPreviewItem(
                        background: AnyView(MagicBackground.strawberry),
                        title: "Strawberry",
                        textColor: .primary
                    )

                    BackgroundPreviewItem(
                        background: AnyView(MagicBackground.kiwi),
                        title: "Kiwi",
                        textColor: .primary
                    )
                }
            }
            .padding()
        }

        .tabItem {
            Image(systemName: "leaf.fill")
            Text("水果")
        }
    }
}
#endif

// MARK: - View Extensions

