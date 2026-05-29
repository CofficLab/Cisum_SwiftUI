import SwiftUI

extension MagicBackground {
    public static var deepOceanCurrent: some View {
        ZStack {
            // 基础海水
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "1E4D6B").opacity(0.9), // 深海蓝
                    Color(hex: "0A2E38").opacity(0.9), // 深渊蓝
                ]),
                startPoint: .top,
                endPoint: .bottom
            )

            // 水流效果
            ForEach(0 ..< 4) { index in
                Wave(phase: .degrees(Double(index) * 90))
                    .fill(Color.white.opacity(0.1))
                    .blur(radius: 20)
            }

            // 光线穿透效果
            GeometryReader { geometry in
                ForEach(0 ..< 3) { _ in
                    Path { path in
                        let startX = CGFloat.random(in: 0 ... geometry.size.width)
                        path.move(to: CGPoint(x: startX, y: 0))
                        path.addLine(to: CGPoint(x: startX + 100, y: geometry.size.height))
                    }
                    .stroke(Color.white.opacity(0.2), lineWidth: 70)
                    .blur(radius: 40)
                }
            }
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }

    public static var tropicalWaters: some View {
        ZStack {
            // 基础水色
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "40E0D0").opacity(0.6), // 绿松石色
                    Color(hex: "0099CC").opacity(0.7), // 蓝绿色
                    Color(hex: "006994").opacity(0.8), // 深蓝色
                ]),
                startPoint: .top,
                endPoint: .bottom
            )

            // 波光效果
            GeometryReader { geometry in
                ForEach(0 ..< 30) { _ in
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: CGFloat.random(in: 5 ... 15))
                        .position(
                            x: CGFloat.random(in: 0 ... geometry.size.width),
                            y: CGFloat.random(in: 0 ... geometry.size.height)
                        )
                        .blur(radius: 5)
                }
            }

            // 水面波纹
            ForEach(0 ..< 3) { index in
                Wave(phase: .degrees(Double(index) * 120))
                    .fill(Color.white.opacity(0.1))
                    .blur(radius: 10)
            }
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }

    public static var coralReef: some View {
        ZStack {
            // 基础水色
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "0077BE").opacity(0.7), // 深海蓝
                    Color(hex: "48D1CC").opacity(0.6), // 绿松石
                    Color(hex: "40E0D0").opacity(0.5), // 青绿
                ]),
                startPoint: .top,
                endPoint: .bottom
            )

            // 珊瑚效果
            GeometryReader { geometry in
                ForEach(0 ..< 15) { _ in
                    Path { path in
                        let startX = CGFloat.random(in: 0 ... geometry.size.width)
                        let startY = geometry.size.height - CGFloat.random(in: 0 ... 100)
                        path.move(to: CGPoint(x: startX, y: startY))

                        for _ in 0 ..< 3 {
                            let controlPoint1 = CGPoint(
                                x: startX + CGFloat.random(in: -30 ... 30),
                                y: startY - CGFloat.random(in: 20 ... 40)
                            )
                            let controlPoint2 = CGPoint(
                                x: startX + CGFloat.random(in: -30 ... 30),
                                y: startY - CGFloat.random(in: 40 ... 60)
                            )
                            let endPoint = CGPoint(
                                x: startX + CGFloat.random(in: -20 ... 20),
                                y: startY - CGFloat.random(in: 60 ... 80)
                            )
                            path.addCurve(to: endPoint,
                                          control1: controlPoint1,
                                          control2: controlPoint2)
                        }
                    }
                    .stroke(
                        Color(hex: "FF69B4").opacity(0.3), // 珊瑚粉
                        lineWidth: CGFloat.random(in: 2 ... 5)
                    )
                    .blur(radius: 3)
                }

                // 气泡效果
                ForEach(0 ..< 20) { _ in
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: CGFloat.random(in: 4 ... 12))
                        .position(
                            x: CGFloat.random(in: 0 ... geometry.size.width),
                            y: CGFloat.random(in: 0 ... geometry.size.height)
                        )
                        .blur(radius: 2)
                }
            }
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
}

#if DEBUG
#Preview("Ocean Themes") {
    TabView {
        // 海洋主题
        ScrollView {
            VStack(spacing: 20) {
                Text("海洋主题")
                    .font(.headline)
                    .padding(.top)

                Group {
                    BackgroundPreviewItem(
                        background: AnyView(MagicBackground.deepOceanCurrent),
                        title: "Deep Ocean Current"
                    )

                    BackgroundPreviewItem(
                        background: AnyView(MagicBackground.tropicalWaters),
                        title: "Tropical Waters"
                    )

                    BackgroundPreviewItem(
                        background: AnyView(MagicBackground.coralReef),
                        title: "Coral Reef"
                    )
                }
            }
            .padding()
        }

        .tabItem {
            Image(systemName: "water.waves")
            Text("海洋")
        }
    }
    .frame(height: 700)
    .frame(width: 900)
}
#endif

// MARK: - View Extensions

