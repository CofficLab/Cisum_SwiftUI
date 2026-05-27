import SwiftUI

extension MagicBackground {
    public static var snowPeak: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "E8E8E8").opacity(0.9), // 雪白
                    Color(hex: "B8D8E8").opacity(0.7), // 冰蓝
                    Color(hex: "7AA1B8").opacity(0.6), // 山岩蓝
                ]),
                startPoint: .top,
                endPoint: .bottom
            )

            // 雪花效果
            GeometryReader { geometry in
                ForEach(0 ..< 50) { _ in
                    Circle()
                        .fill(Color.white.opacity(Double.random(in: 0.3 ... 0.7)))
                        .frame(width: CGFloat.random(in: 2 ... 4))
                        .position(
                            x: CGFloat.random(in: 0 ... geometry.size.width),
                            y: CGFloat.random(in: 0 ... geometry.size.height)
                        )
                        .blur(radius: 1)
                }
            }

            // 山峰轮廓
            GeometryReader { geometry in
                Path { path in
                    path.move(to: CGPoint(x: 0, y: geometry.size.height))
                    path.addLine(to: CGPoint(x: geometry.size.width * 0.3, y: geometry.size.height * 0.4))
                    path.addLine(to: CGPoint(x: geometry.size.width * 0.5, y: geometry.size.height * 0.6))
                    path.addLine(to: CGPoint(x: geometry.size.width * 0.7, y: geometry.size.height * 0.3))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height * 0.5))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height))
                    path.closeSubpath()
                }
                .fill(Color.white.opacity(0.3))
                .blur(radius: 20)
            }
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }

    public static var glacierIce: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "A5DEE5").opacity(0.7), // 冰川蓝
                    Color(hex: "E0FFFF").opacity(0.6), // 浅蓝
                    Color(hex: "F0FFFF").opacity(0.8), // 纯白
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // 将冰晶效果拆分成子视图
            IceCrystals()
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }

    public static var frostMountain: some View {
        ZStack {
            // 基础渐变
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "E3F4F4").opacity(0.8), // 霜白
                    Color(hex: "D4F1F4").opacity(0.7), // 冰蓝
                    Color(hex: "B1D4E0").opacity(0.6), // 深冰蓝
                ]),
                startPoint: .top,
                endPoint: .bottom
            )

            // 冰霜效果
            GeometryReader { geometry in
                ForEach(0 ..< 30) { _ in
                    Path { path in
                        let startPoint = CGPoint(
                            x: CGFloat.random(in: 0 ... geometry.size.width),
                            y: CGFloat.random(in: 0 ... geometry.size.height)
                        )
                        path.move(to: startPoint)

                        for _ in 0 ..< 3 {
                            let endPoint = CGPoint(
                                x: startPoint.x + CGFloat.random(in: -20 ... 20),
                                y: startPoint.y + CGFloat.random(in: -20 ... 20)
                            )
                            path.addLine(to: endPoint)
                        }
                    }
                    .stroke(Color.white.opacity(0.4), lineWidth: 1)
                    .blur(radius: 1)
                }

                // 雾气效果
                ForEach(0 ..< 5) { _ in
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: CGFloat.random(in: 100 ... 200))
                        .position(
                            x: CGFloat.random(in: 0 ... geometry.size.width),
                            y: CGFloat.random(in: 0 ... geometry.size.height)
                        )
                        .blur(radius: 30)
                }
            }
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
}

// 添加一个新的结构体来处理冰晶绘制
private struct IceCrystals: View {
    var body: some View {
        GeometryReader { geometry in
            ForEach(0 ..< 20) { _ in
                IceCrystal(
                    center: CGPoint(
                        x: CGFloat.random(in: 0 ... geometry.size.width),
                        y: CGFloat.random(in: 0 ... geometry.size.height)
                    ),
                    size: CGFloat.random(in: 10 ... 30)
                )
            }
        }
    }
}

private struct IceCrystal: View {
    let center: CGPoint
    let size: CGFloat

    var body: some View {
        Path { path in
            for i in 0 ..< 6 {
                let angle = Double(i) * .pi / 3
                path.move(to: center)
                path.addLine(to: CGPoint(
                    x: center.x + size * cos(angle),
                    y: center.y + size * sin(angle)
                ))
            }
        }
        .stroke(Color.white.opacity(0.3), lineWidth: 1)
        .blur(radius: 2)
    }
}

#if DEBUG
#Preview("Snow Themes") {
    TabView {
        // 雪景主题
        ScrollView {
            VStack(spacing: 20) {
                Text("雪景主题")
                    .font(.headline)
                    .padding(.top)

                Group {
                    BackgroundPreviewItem(
                        background: AnyView(MagicBackground.snowPeak),
                        title: "Snow Peak",
                        textColor: .primary
                    )

                    BackgroundPreviewItem(
                        background: AnyView(MagicBackground.glacierIce),
                        title: "Glacier Ice",
                        textColor: .primary
                    )

                    BackgroundPreviewItem(
                        background: AnyView(MagicBackground.frostMountain),
                        title: "Frost Mountain",
                        textColor: .primary
                    )
                }
            }
            .padding()
        }

        .tabItem {
            Image(systemName: "snow")
            Text("雪景")
        }
    }
}
#endif

// MARK: - View Extensions

