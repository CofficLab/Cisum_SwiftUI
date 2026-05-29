import SwiftUI

extension MagicBackground {
    public static var sunnyBeach: some View {
        ZStack {
            // 基础渐变
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "87CEEB").opacity(0.8), // 天空蓝
                    Color(hex: "E6B980").opacity(0.7), // 沙滩金
                    Color(hex: "EAC5A3").opacity(0.6), // 浅沙色
                ]),
                startPoint: .top,
                endPoint: .bottom
            )

            // 波浪效果
            GeometryReader { geometry in
                let waveHeight = geometry.size.height * 0.4
                let baseY = geometry.size.height * 0.6

                // 多层波浪
                ForEach(0 ..< 3) { index in
                    Wave(phase: .degrees(Double(index) * 120))
                        .fill(Color(hex: "40E0D0").opacity(0.2))
                        .frame(height: waveHeight)
                        .offset(y: baseY)
                        .blur(radius: 10)
                }

                // 阳光反射
                Path { path in
                    path.move(to: CGPoint(x: geometry.size.width * 0.3, y: 0))
                    path.addLine(to: CGPoint(x: geometry.size.width * 0.7, y: geometry.size.height * 0.7))
                }
                .stroke(Color.white.opacity(0.3), lineWidth: 100)
                .blur(radius: 30)
            }
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }

    public static var tropicalSunset: some View {
        ZStack {
            // 日落渐变
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "FF6B6B").opacity(0.7), // 橙红
                    Color(hex: "FFB88C").opacity(0.6), // 橙色
                    Color(hex: "4CA1AF").opacity(0.5), // 海蓝
                ]),
                startPoint: .top,
                endPoint: .bottom
            )

            // 太阳效果
            GeometryReader { geometry in
                Circle()
                    .fill(Color(hex: "FF4500").opacity(0.6))
                    .frame(width: 100, height: 100)
                    .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.3)
                    .blur(radius: 20)

                // 反射
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "FF4500").opacity(0.3),
                                Color.clear,
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 40, height: geometry.size.height * 0.5)
                    .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.6)
                    .blur(radius: 15)
            }
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }

    public static var palmBeach: some View {
        ZStack {
            // 基础渐变
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "00B4DB").opacity(0.7), // 热带蓝
                    Color(hex: "0083B0").opacity(0.6), // 深蓝
                    Color(hex: "DEB887").opacity(0.5), // 沙滩色
                ]),
                startPoint: .top,
                endPoint: .bottom
            )

            // 将复杂的棕榈树绘制逻辑拆分成子视图
            PalmTrees()

            // 修复海浪效果的 Wave 参数
            GeometryReader { geometry in
                ForEach(0 ..< 4) { index in
                    Wave(phase: .degrees(Double(index) * 90))
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 50)
                        .offset(y: geometry.size.height * 0.7)
                }
            }
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
}

// 添加一个新的结构体来处理棕榈树绘制
private struct PalmTrees: View {
    var body: some View {
        GeometryReader { geometry in
            ForEach(0 ..< 3) { index in
                PalmTree(
                    baseX: geometry.size.width * CGFloat(index + 1) / 4,
                    baseY: geometry.size.height * 0.7
                )
            }
        }
    }
}

private struct PalmTree: View {
    let baseX: CGFloat
    let baseY: CGFloat

    var body: some View {
        Path { path in
            // 树干
            path.move(to: CGPoint(x: baseX, y: baseY))
            path.addQuadCurve(
                to: CGPoint(x: baseX + 20, y: baseY - 100),
                control: CGPoint(x: baseX + 30, y: baseY - 50)
            )

            // 树叶
            for i in 0 ..< 5 {
                let angle = Double(i) * .pi / 6 - .pi / 3
                let length = CGFloat.random(in: 40 ... 60)
                path.move(to: CGPoint(x: baseX + 10, y: baseY - CGFloat.random(in: 40 ... 90)))
                path.addLine(to: CGPoint(
                    x: baseX + 10 + length * cos(angle),
                    y: baseY - CGFloat.random(in: 40 ... 90) - length * sin(angle)
                ))
            }
        }
        .stroke(Color.black.opacity(0.3), lineWidth: 2)
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Beach Themes") {
    TabView {
        // 海滩主题
        ScrollView {
            VStack(spacing: 20) {
                Text("海滩主题")
                    .font(.headline)
                    .padding(.top)

                BackgroundPreviewItem(
                    background: AnyView(MagicBackground.sunnyBeach),
                    title: "Sunny Beach",
                    textColor: .primary
                )

                BackgroundPreviewItem(
                    background: AnyView(MagicBackground.tropicalSunset),
                    title: "Tropical Sunset"
                )

                BackgroundPreviewItem(
                    background: AnyView(MagicBackground.palmBeach),
                    title: "Palm Beach",
                    textColor: .primary
                )
            }
            .padding()
        }

        .tabItem {
            Image(systemName: "sun.horizon.fill")
            Text("海滩")
        }
    }
}
#endif

// MARK: - View Extensions

