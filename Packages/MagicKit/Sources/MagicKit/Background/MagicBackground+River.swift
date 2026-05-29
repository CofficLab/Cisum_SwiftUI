import SwiftUI

extension MagicBackground {
    public static var mountainStream: some View {
        ZStack {
            // 基础渐变
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "3494E6").opacity(0.7), // 河流蓝
                    Color(hex: "86A8E7").opacity(0.6), // 浅蓝
                    Color(hex: "91EAE4").opacity(0.5), // 青绿
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // 流水纹理
            GeometryReader { geometry in
                ForEach(0 ..< 5) { index in
                    Path { path in
                        var x: CGFloat = 0
                        var y = CGFloat.random(in: 0 ... geometry.size.height)
                        path.move(to: CGPoint(x: x, y: y))

                        while x < geometry.size.width {
                            x += CGFloat.random(in: 30 ... 50)
                            y += CGFloat.random(in: -20 ... 20)
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                    .stroke(Color.white.opacity(0.2), lineWidth: 2)
                    .blur(radius: 3)
                    .offset(y: CGFloat(index) * 50)
                }

                // 水花效果
                ForEach(0 ..< 20) { _ in
                    Circle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: CGFloat.random(in: 2 ... 6))
                        .position(
                            x: CGFloat.random(in: 0 ... geometry.size.width),
                            y: CGFloat.random(in: 0 ... geometry.size.height)
                        )
                        .blur(radius: 1)
                }
            }
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }

    public static var calmRiver: some View {
        ZStack {
            // 基础渐变
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "76B852").opacity(0.3), // 河岸绿
                    Color(hex: "8DC26F").opacity(0.3), // 浅绿
                    Color(hex: "4CA1AF").opacity(0.6), // 河水蓝
                ]),
                startPoint: .top,
                endPoint: .bottom
            )

            // 倒影效果
            GeometryReader { geometry in
                ForEach(0 ..< 8) { _ in
                    Path { path in
                        let startX = CGFloat.random(in: 0 ... geometry.size.width)
                        let startY = CGFloat.random(in: 0 ... geometry.size.height / 3)
                        path.move(to: CGPoint(x: startX, y: startY))

                        let endY = startY + CGFloat.random(in: 50 ... 100)
                        path.addLine(to: CGPoint(x: startX, y: endY))
                    }
                    .stroke(
                        Color.white.opacity(0.2),
                        lineWidth: CGFloat.random(in: 1 ... 3)
                    )
                    .blur(radius: 2)
                }

                // 涟漪效果
                ForEach(0 ..< 10) { _ in
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        .frame(width: CGFloat.random(in: 20 ... 60))
                        .position(
                            x: CGFloat.random(in: 0 ... geometry.size.width),
                            y: CGFloat.random(in: geometry.size.height / 2 ... geometry.size.height)
                        )
                        .blur(radius: 2)
                }
            }
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }

    public static var cascadingRiver: some View {
        ZStack {
            // 基础渐变
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "1A2980").opacity(0.6), // 深蓝
                    Color(hex: "26D0CE").opacity(0.5), // 浅绿蓝
                ]),
                startPoint: .top,
                endPoint: .bottom
            )

            // 瀑布效果
            GeometryReader { geometry in
                ForEach(0 ..< 15) { _ in
                    Path { path in
                        let startX = CGFloat.random(in: 0 ... geometry.size.width)
                        path.move(to: CGPoint(x: startX, y: 0))

                        var currentY: CGFloat = 0
                        while currentY < geometry.size.height {
                            currentY += CGFloat.random(in: 10 ... 30)
                            let newX = startX + CGFloat.random(in: -10 ... 10)
                            path.addLine(to: CGPoint(x: newX, y: currentY))
                        }
                    }
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    .blur(radius: 1)
                }

                // 水雾效果
                ForEach(0 ..< 20) { _ in
                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: CGFloat.random(in: 5 ... 15))
                        .position(
                            x: CGFloat.random(in: 0 ... geometry.size.width),
                            y: CGFloat.random(in: 0 ... geometry.size.height)
                        )
                        .blur(radius: 3)
                }
            }
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
}

#if DEBUG
#Preview("River Themes") {
    TabView {
        // 河流主题
        ScrollView {
            VStack(spacing: 20) {
                Text("河流主题")
                    .font(.headline)
                    .padding(.top)

                Group {
                    BackgroundPreviewItem(
                        background: AnyView(MagicBackground.mountainStream),
                        title: "Mountain Stream",
                        textColor: .primary
                    )

                    BackgroundPreviewItem(
                        background: AnyView(MagicBackground.calmRiver),
                        title: "Calm River"
                    )

                    BackgroundPreviewItem(
                        background: AnyView(MagicBackground.cascadingRiver),
                        title: "Cascading River",
                        textColor: .primary
                    )
                }
            }
            .padding()
        }

        .tabItem {
            Image(systemName: "drop.fill")
            Text("河流")
        }
    }
}
#endif

// MARK: - View Extensions

