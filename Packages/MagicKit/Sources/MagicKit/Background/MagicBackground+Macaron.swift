import SwiftUI

extension MagicBackground {
    public static var vanillaMacaron: some View {
        ZStack {
            // 香草奶油色
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "FFF8DC").opacity(0.7), // 玉米丝色
                    Color(hex: "FAEBD7").opacity(0.6), // 古董白
                ]),
                startPoint: .top,
                endPoint: .bottom
            )

            // 简单的圆形装饰
            Circle()
                .fill(Color.white.opacity(0.3))
                .frame(width: 200)
                .blur(radius: 30)
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }

    public static var roseMacaron: some View {
        ZStack {
            // 玫瑰粉色
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "FFB6C1").opacity(0.7), // 浅粉红
                    Color(hex: "FFC0CB").opacity(0.6), // 粉红色
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // 简单的装饰线条
            VStack(spacing: 30) {
                ForEach(0 ..< 3) { _ in
                    Capsule()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 100, height: 4)
                }
            }
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }

    public static var lavenderMacaron: some View {
        ZStack {
            // 薰衣草紫色
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "E6E6FA").opacity(0.7), // 薰衣草色
                    Color(hex: "D8BFD8").opacity(0.6), // 蓟色
                ]),
                startPoint: .top,
                endPoint: .bottom
            )

            // 简单的波浪纹理
            GeometryReader { geometry in
                Path { path in
                    path.move(to: CGPoint(x: 0, y: geometry.size.height * 0.5))
                    path.addCurve(
                        to: CGPoint(x: geometry.size.width, y: geometry.size.height * 0.5),
                        control1: CGPoint(x: geometry.size.width * 0.3, y: geometry.size.height * 0.4),
                        control2: CGPoint(x: geometry.size.width * 0.7, y: geometry.size.height * 0.6)
                    )
                }
                .stroke(Color.white.opacity(0.3), lineWidth: 2)
            }
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }

    public static var mintMacaron: some View {
        ZStack {
            // 薄荷绿色
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "98FF98").opacity(0.7), // 薄荷绿
                    Color(hex: "F0FFF0").opacity(0.6), // 蜜瓜绿
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )

            // 简单的点状装饰
            VStack(spacing: 20) {
                ForEach(0 ..< 3) { _ in
                    HStack(spacing: 20) {
                        ForEach(0 ..< 3) { _ in
                            Circle()
                                .fill(Color.white.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                    }
                }
            }
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }

    public static var lemonMacaron: some View {
        ZStack {
            // 柠檬黄色
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "FFFACD").opacity(0.7), // 柠檬绸色
                    Color(hex: "FAFAD2").opacity(0.6), // 浅秋麒麟黄
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // 简单的放射状装饰
            Circle()
                .strokeBorder(Color.white.opacity(0.3), lineWidth: 2)
                .frame(width: 200)

            Circle()
                .strokeBorder(Color.white.opacity(0.2), lineWidth: 2)
                .frame(width: 150)
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
}

#if DEBUG
#Preview("Macaron Themes") {
    TabView {
        // 马卡龙主题
        ScrollView {
            VStack(spacing: 20) {
                Text("马卡龙主题")
                    .font(.headline)
                    .padding(.top)

                Group {
                    BackgroundPreviewItem(
                        background: AnyView(MagicBackground.vanillaMacaron),
                        title: "Vanilla",
                        textColor: .primary
                    )

                    BackgroundPreviewItem(
                        background: AnyView(MagicBackground.roseMacaron),
                        title: "Rose",
                        textColor: .primary
                    )

                    BackgroundPreviewItem(
                        background: AnyView(MagicBackground.lavenderMacaron),
                        title: "Lavender",
                        textColor: .primary
                    )

                    BackgroundPreviewItem(
                        background: AnyView(MagicBackground.mintMacaron),
                        title: "Mint",
                        textColor: .primary
                    )

                    BackgroundPreviewItem(
                        background: AnyView(MagicBackground.lemonMacaron),
                        title: "Lemon",
                        textColor: .primary
                    )
                }
            }
            .padding()
        }

        .tabItem {
            Image(systemName: "circle.grid.2x2.fill")
            Text("马卡龙")
        }
    }
}
#endif

// MARK: - View Extensions

