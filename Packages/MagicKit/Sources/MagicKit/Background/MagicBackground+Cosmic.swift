import SwiftUI

extension MagicBackground {
    public static var cosmicDust: some View {
        ZStack {
            Color("13111C").opacity(0.7)

            LinearGradient(
                gradient: Gradient(colors: [
                    Color("642B73").opacity(0.6),
                    Color("C6426E").opacity(0.4),
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // 星尘效果
            GeometryReader { geometry in
                ForEach(0 ..< 30) { _ in
                    Circle()
                        .fill(Color.white.opacity(Double.random(in: 0.1 ... 0.3)))
                        .frame(width: CGFloat.random(in: 2 ... 4))
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

    public static var galaxySpiral: some View {
        ZStack {
            // 深空背景
            Color("0B0B1A").opacity(0.9)

            // 星云效果
            RadialGradient(
                gradient: Gradient(colors: [
                    Color("4B0082").opacity(0.4), // 深紫
                    Color("800080").opacity(0.3), // 紫
                    Color("9400D3").opacity(0.2), // 紫罗兰
                ]),
                center: .center,
                startRadius: 100,
                endRadius: 400
            )
            .blur(radius: 30)

            // 星星层
            GeometryReader { geometry in
                ZStack {
                    // 小星星
                    ForEach(0 ..< 50) { _ in
                        Circle()
                            .fill(Color.white)
                            .frame(width: CGFloat.random(in: 1 ... 2))
                            .position(
                                x: CGFloat.random(in: 0 ... geometry.size.width),
                                y: CGFloat.random(in: 0 ... geometry.size.height)
                            )
                    }

                    // 亮星
                    ForEach(0 ..< 10) { _ in
                        Circle()
                            .fill(Color.white)
                            .frame(width: CGFloat.random(in: 2 ... 3))
                            .blur(radius: 0.5)
                            .position(
                                x: CGFloat.random(in: 0 ... geometry.size.width),
                                y: CGFloat.random(in: 0 ... geometry.size.height)
                            )
                    }
                }
            }
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }

    public static var nebulaMist: some View {
        ZStack {
            // 基础背景
            Color("090418").opacity(0.95)

            // 星云效果
            ZStack {
                // 蓝色星云
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color("00BFFF").opacity(0.2),
                        Color("1E90FF").opacity(0.1),
                        Color.clear,
                    ]),
                    center: .topLeading,
                    startRadius: 100,
                    endRadius: 300
                )
                .blur(radius: 20)

                // 粉色星云
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "FF69B4").opacity(0.2),
                        Color(hex: "FF1493").opacity(0.1),
                        Color.clear,
                    ]),
                    center: .bottomTrailing,
                    startRadius: 150,
                    endRadius: 350
                )
                .blur(radius: 25)
            }

            // 星尘效果
            GeometryReader { geometry in
                ForEach(0 ..< 40) { _ in
                    Circle()
                        .fill(Color.white.opacity(Double.random(in: 0.3 ... 0.7)))
                        .frame(width: CGFloat.random(in: 1 ... 3))
                        .blur(radius: CGFloat.random(in: 0 ... 0.5))
                        .position(
                            x: CGFloat.random(in: 0 ... geometry.size.width),
                            y: CGFloat.random(in: 0 ... geometry.size.height)
                        )
                }
            }
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }

    public static var darkMatter: some View {
        ZStack {
            // 深空背景
            Color("000000").opacity(0.95)

            // 暗物质效果
            GeometryReader { geometry in
                ZStack {
                    // 神秘光晕
                    ForEach(0 ..< 5) { _ in
                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [
                                        Color("4B0082").opacity(0.2),
                                        Color.clear,
                                    ]),
                                    center: .center,
                                    startRadius: 50,
                                    endRadius: 150
                                )
                            )
                            .frame(width: CGFloat.random(in: 200 ... 300))
                            .position(
                                x: CGFloat.random(in: 0 ... geometry.size.width),
                                y: CGFloat.random(in: 0 ... geometry.size.height)
                            )
                            .blur(radius: 30)
                    }

                    // 微弱星光
                    ForEach(0 ..< 30) { _ in
                        Circle()
                            .fill(Color.white.opacity(Double.random(in: 0.1 ... 0.3)))
                            .frame(width: CGFloat.random(in: 1 ... 2))
                            .position(
                                x: CGFloat.random(in: 0 ... geometry.size.width),
                                y: CGFloat.random(in: 0 ... geometry.size.height)
                            )
                    }
                }
            }
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }

    public static var cosmicPortal: some View {
        ZStack {
            // 深空背景
            Color("0A0A2A").opacity(0.95)

            // 漩涡效果
            GeometryReader { geometry in
                let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)

                ForEach(0 ..< 8) { index in
                    let rotation = Double(index) * .pi / 4

                    Path { path in
                        path.move(to: center)
                        path.addArc(
                            center: center,
                            radius: 150,
                            startAngle: .degrees(rotation * 180 / .pi),
                            endAngle: .degrees((rotation + 0.5) * 180 / .pi),
                            clockwise: false
                        )
                    }
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "4B0082").opacity(0.4),
                                Color(hex: "9400D3").opacity(0.2),
                                Color.clear,
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 2
                    )
                    .blur(radius: 5)
                }

                // 中心光芒
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.3),
                                Color(hex: "4B0082").opacity(0.2),
                                Color.clear,
                            ]),
                            center: .center,
                            startRadius: 5,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)
                    .position(center)
                    .blur(radius: 15)
            }
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
}

// 添加预览
#if DEBUG
#Preview("Cosmic Themes") {
    TabView {
        // 宇宙主题
        ScrollView {
            VStack(spacing: 20) {
                Text("宇宙主题")
                    .font(.headline)
                    .padding(.top)

                Group {
                    BackgroundPreviewItem(
                        background: AnyView(MagicBackground.cosmicDust),
                        title: "Cosmic Dust"
                    )

                    BackgroundPreviewItem(
                        background: AnyView(MagicBackground.galaxySpiral),
                        title: "Galaxy Spiral"
                    )

                    BackgroundPreviewItem(
                        background: AnyView(MagicBackground.nebulaMist),
                        title: "Nebula Mist"
                    )

                    BackgroundPreviewItem(
                        background: AnyView(MagicBackground.darkMatter),
                        title: "Dark Matter"
                    )

                    BackgroundPreviewItem(
                        background: AnyView(MagicBackground.cosmicPortal),
                        title: "Cosmic Portal"
                    )
                }
            }
            .padding()
        }

        .tabItem {
            Image(systemName: "sparkles")
            Text("宇宙")
        }
    }
}
#endif

// MARK: - View Extensions

