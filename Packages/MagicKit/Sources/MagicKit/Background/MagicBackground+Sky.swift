import SwiftUI

extension MagicBackground {
    public static var dawnSky: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "FF9A9E").opacity(0.7), // 晨曦粉
                    Color(hex: "FAD0C4").opacity(0.7), // 淡橙
                    Color(hex: "B5E8FF").opacity(0.7), // 天蓝
                ]),
                startPoint: .top,
                endPoint: .bottom
            )

            // 云彩效果
            GeometryReader { geometry in
                ForEach(0 ..< 5) { _ in
                    Circle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: CGFloat.random(in: 100 ... 200))
                        .position(
                            x: CGFloat.random(in: 0 ... geometry.size.width),
                            y: CGFloat.random(in: 0 ... geometry.size.height / 2)
                        )
                        .blur(radius: 30)
                }
            }

            // 晨光效果
            RadialGradient(
                gradient: Gradient(colors: [
                    Color(hex: "FFD700").opacity(0.2),
                    Color.clear,
                ]),
                center: .top,
                startRadius: 100,
                endRadius: 400
            )
            .blur(radius: 20)
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }

    public static var stormyHeaven: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "2C3E50").opacity(0.8), // 暴风蓝
                    Color(hex: "3498DB").opacity(0.6), // 电光蓝
                    Color(hex: "2C3E50").opacity(0.8), // 暴风蓝
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // 闪电效果
            GeometryReader { geometry in
                ForEach(0 ..< 3) { _ in
                    Path { path in
                        var x = CGFloat.random(in: 0 ... geometry.size.width)
                        var y: CGFloat = 0
                        path.move(to: CGPoint(x: x, y: y))

                        while y < geometry.size.height {
                            x += CGFloat.random(in: -50 ... 50)
                            y += CGFloat.random(in: 20 ... 60)
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
                    .blur(radius: 3)
                }
            }

            // 乌云效果
            GeometryReader { geometry in
                ForEach(0 ..< 8) { _ in
                    Circle()
                        .fill(Color(hex: "1C2833").opacity(0.4))
                        .frame(width: CGFloat.random(in: 150 ... 300))
                        .position(
                            x: CGFloat.random(in: 0 ... geometry.size.width),
                            y: CGFloat.random(in: 0 ... geometry.size.height / 2)
                        )
                        .blur(radius: 20)
                }
            }
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }

    public static var sunsetGlow: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "FF6B6B").opacity(0.7), // 橙红
                    Color(hex: "FFB88C").opacity(0.6), // 橙色
                    Color(hex: "4A90E2").opacity(0.5), // 天蓝
                ]),
                startPoint: .top,
                endPoint: .bottom
            )

            // 太阳效果
            GeometryReader { geometry in
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "FF4500").opacity(0.7),
                                Color(hex: "FF6B6B").opacity(0.3),
                                Color.clear,
                            ]),
                            center: .center,
                            startRadius: 50,
                            endRadius: 150
                        )
                    )
                    .frame(width: 200, height: 200)
                    .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.3)
                    .blur(radius: 20)

                // 云彩效果
                ForEach(0 ..< 6) { _ in
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: CGFloat.random(in: 100 ... 200))
                        .position(
                            x: CGFloat.random(in: 0 ... geometry.size.width),
                            y: CGFloat.random(in: 0 ... geometry.size.height * 0.6)
                        )
                        .blur(radius: 25)
                }
            }
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
}

#if DEBUG
#Preview("Sky Themes") {
    TabView {
        // 天空主题
        ScrollView {
            VStack(spacing: 20) {
                Text("天空主题")
                    .font(.headline)
                    .padding(.top)

                Group {
                    BackgroundPreviewItem(
                        background: AnyView(MagicBackground.dawnSky),
                        title: "Dawn Sky",
                        textColor: .primary
                    )

                    BackgroundPreviewItem(
                        background: AnyView(MagicBackground.stormyHeaven),
                        title: "Stormy Heaven"
                    )

                    BackgroundPreviewItem(
                        background: AnyView(MagicBackground.sunsetGlow),
                        title: "Sunset Glow"
                    )
                }
            }
            .padding()
        }

        .tabItem {
            Image(systemName: "cloud.sun.fill")
            Text("天空")
        }
    }
}
#endif

// MARK: - View Extensions

