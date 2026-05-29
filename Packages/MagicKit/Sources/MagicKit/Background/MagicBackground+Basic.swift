import SwiftUI

extension MagicBackground {
    /// 霜花背景效果
    ///
    /// 创建一个具有毛玻璃效果和霜花图案的背景视图。
    /// 使用超薄材质作为基础，并在其上绘制随机分布的霜花线条图案。
    ///
    /// - Returns: 包含霜花效果的背景视图
    public static var frost: some View {
        ZStack {
            // 基础毛玻璃效果
            Rectangle()
                .fill(.ultraThinMaterial)

            // 霜花效果
            GeometryReader { geometry in
                ForEach(0 ..< 10) { _ in
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
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    .blur(radius: 1)
                }
            }
        }
        .ignoresSafeArea()
    }

    /// 渐变背景效果
    ///
    /// 创建一个从浅蓝到深紫的线性渐变背景。
    /// 渐变方向从顶部到底部，使用超薄材质作为背景层。
    ///
    /// - Returns: 蓝紫色渐变背景视图
    public static var gradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(hex: "a8c0ff").opacity(0.7),
                Color(hex: "3f2b96").opacity(0.7),
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }

    /// 极光背景效果
    ///
    /// 创建一个模拟北极光的动态背景效果。
    /// 使用曲线路径和渐变色彩模拟极光的流动效果，
    /// 包含绿色到青色的渐变和模糊效果。
    ///
    /// - Returns: 极光效果背景视图
    public static var aurora: some View {
        ZStack {
            Color.black.opacity(0.8)

            // 极光效果
            GeometryReader { geometry in
                ForEach(0 ..< 3) { index in
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: geometry.size.height * 0.4))
                        path.addCurve(
                            to: CGPoint(x: geometry.size.width, y: geometry.size.height * 0.4),
                            control1: CGPoint(x: geometry.size.width * 0.3, y: geometry.size.height * 0.3),
                            control2: CGPoint(x: geometry.size.width * 0.7, y: geometry.size.height * 0.5)
                        )
                    }
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "00ff87").opacity(0.3),
                                Color(hex: "60efff").opacity(0.3),
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 50
                    )
                    .blur(radius: 30)
                    .offset(y: CGFloat(index) * 30)
                }
            }
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }

    /// 海洋背景效果
    ///
    /// 创建一个模拟海洋深度的渐变背景。
    /// 从浅蓝色渐变到深蓝色，营造海洋的深邃感。
    ///
    /// - Returns: 海洋色调渐变背景视图
    public static var ocean: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(hex: "1CB5E0").opacity(0.7),
                Color(hex: "000046").opacity(0.7),
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }

    /// 日落背景效果
    ///
    /// 创建一个温暖的日落色调渐变背景。
    /// 从橙红色渐变到金黄色，模拟夕阳西下的美景。
    ///
    /// - Returns: 日落色调渐变背景视图
    public static var sunset: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(hex: "FF512F").opacity(0.7),
                Color(hex: "F09819").opacity(0.7),
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }

    /// 森林背景效果
    ///
    /// 创建一个自然森林色调的对角渐变背景。
    /// 从深绿色渐变到浅绿色，营造森林的清新感。
    ///
    /// - Returns: 森林色调渐变背景视图
    public static var forest: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(hex: "134E5E").opacity(0.7),
                Color(hex: "71B280").opacity(0.7),
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }

    /// 薰衣草背景效果
    ///
    /// 创建一个柔和的薰衣草色调渐变背景。
    /// 从浅紫色渐变到深紫色，营造优雅宁静的氛围。
    ///
    /// - Returns: 薰衣草色调渐变背景视图
    public static var lavender: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(hex: "E6E6FA").opacity(0.7),
                Color(hex: "9890E3").opacity(0.7),
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }

    /// 沙漠背景效果
    ///
    /// 创建一个温暖的沙漠色调水平渐变背景。
    /// 从金黄色渐变到橙色，模拟沙漠的炽热感。
    ///
    /// - Returns: 沙漠色调渐变背景视图
    public static var desert: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(hex: "FFB75E").opacity(0.7),
                Color(hex: "ED8F03").opacity(0.7),
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }

    /// 午夜背景效果
    ///
    /// 创建一个深沉的午夜色调渐变背景。
    /// 从深灰色渐变到更深的灰色，营造神秘的夜晚氛围。
    ///
    /// - Returns: 午夜色调渐变背景视图
    public static var midnight: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(hex: "232526").opacity(0.7),
                Color(hex: "414345").opacity(0.7),
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }

    /// 樱桃背景效果
    ///
    /// 创建一个鲜艳的樱桃色调对角渐变背景。
    /// 从深红色渐变到橙红色，营造活力四射的感觉。
    ///
    /// - Returns: 樱桃色调渐变背景视图
    public static var cherry: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(hex: "EB3349").opacity(0.7),
                Color(hex: "F45C43").opacity(0.7),
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }

    /// 薄荷背景效果
    ///
    /// 创建一个清新的薄荷色调水平渐变背景。
    /// 从青绿色渐变到浅绿色，营造清新凉爽的感觉。
    ///
    /// - Returns: 薄荷色调渐变背景视图
    public static var mint: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(hex: "00B09B").opacity(0.7),
                Color(hex: "96C93D").opacity(0.7),
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }

    /// 黄昏背景效果
    ///
    /// 创建一个黄昏时分的色调渐变背景。
    /// 从深蓝灰色渐变到亮蓝色，模拟黄昏天空的变化。
    ///
    /// - Returns: 黄昏色调渐变背景视图
    public static var twilight: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(hex: "2C3E50").opacity(0.7),
                Color(hex: "3498DB").opacity(0.7),
            ]),
            startPoint: .bottom,
            endPoint: .top
        )
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }

    /// 玫瑰背景效果
    ///
    /// 创建一个柔美的玫瑰色调渐变背景。
    /// 从粉红色渐变到浅粉色，营造浪漫温柔的氛围。
    ///
    /// - Returns: 玫瑰色调渐变背景视图
    public static var rose: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(hex: "FF9A9E").opacity(0.7),
                Color(hex: "FECFEF").opacity(0.7),
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }

    /// 翡翠背景效果
    ///
    /// 创建一个优雅的翡翠色调对角渐变背景。
    /// 从深绿色渐变到蓝绿色，营造宝石般的质感。
    ///
    /// - Returns: 翡翠色调渐变背景视图
    public static var emerald: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(hex: "348F50").opacity(0.7),
                Color(hex: "56B4D3").opacity(0.7),
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }

    /// 紫水晶背景效果
    ///
    /// 创建一个神秘的紫水晶色调渐变背景。
    /// 从亮紫色渐变到深紫色，营造神秘高贵的感觉。
    ///
    /// - Returns: 紫水晶色调渐变背景视图
    public static var amethyst: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(hex: "9D50BB").opacity(0.7),
                Color(hex: "6E48AA").opacity(0.7),
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }

    /// 珊瑚背景效果
    ///
    /// 创建一个温暖的珊瑚色调水平渐变背景。
    /// 从橙红色渐变到浅橙色，营造温暖活泼的感觉。
    ///
    /// - Returns: 珊瑚色调渐变背景视图
    public static var coral: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(hex: "FF7E5F").opacity(0.7),
                Color(hex: "FEB47B").opacity(0.7),
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }

    /// 石板背景效果
    ///
    /// 创建一个沉稳的石板色调渐变背景。
    /// 从蓝灰色渐变到紫灰色，营造专业稳重的感觉。
    ///
    /// - Returns: 石板色调渐变背景视图
    public static var slate: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(hex: "516395").opacity(0.7),
                Color(hex: "614385").opacity(0.7),
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }

    /// 鼠尾草背景效果
    ///
    /// 创建一个自然的鼠尾草色调对角渐变背景。
    /// 从蓝灰色渐变到绿灰色，营造自然平和的感觉。
    ///
    /// - Returns: 鼠尾草色调渐变背景视图
    public static var sage: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(hex: "96A7CF").opacity(0.7),
                Color(hex: "ABBF90").opacity(0.7),
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }

    /// 黄昏背景效果
    ///
    /// 创建一个戏剧性的黄昏色调渐变背景。
    /// 从深蓝灰色渐变到珊瑚红色，营造黄昏的对比美感。
    ///
    /// - Returns: 黄昏色调渐变背景视图
    public static var dusk: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(hex: "2C3E50").opacity(0.7),
                Color(hex: "FD746C").opacity(0.7),
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }

    /// 宁静背景效果
    ///
    /// 创建一个平静的宁静色调渐变背景。
    /// 从浅蓝色渐变到更浅的蓝色，营造宁静祥和的氛围。
    ///
    /// - Returns: 宁静色调渐变背景视图
    public static var serenity: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(hex: "CFDEF3").opacity(0.7),
                Color(hex: "E0EAFC").opacity(0.7),
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
}

// MARK: - View Extensions



// MARK: - Preview

#if DEBUG
#Preview("Basic Themes") {
    TabView {
        // 基础主题
        VStack(spacing: 20) {
            Group {
                BackgroundPreviewItem(background: AnyView(MagicBackground.frost), title: "Frost", textColor: .primary)
                BackgroundPreviewItem(background: AnyView(MagicBackground.gradient), title: "Gradient")
                BackgroundPreviewItem(background: AnyView(MagicBackground.aurora), title: "Aurora")
                BackgroundPreviewItem(background: AnyView(MagicBackground.ocean), title: "Ocean")
                BackgroundPreviewItem(background: AnyView(MagicBackground.sunset), title: "Sunset", textColor: .primary)
            }

            Group {
                BackgroundPreviewItem(background: AnyView(MagicBackground.forest), title: "Forest")
                BackgroundPreviewItem(background: AnyView(MagicBackground.lavender), title: "Lavender", textColor: .primary)
                BackgroundPreviewItem(background: AnyView(MagicBackground.desert), title: "Desert", textColor: .primary)
                BackgroundPreviewItem(background: AnyView(MagicBackground.midnight), title: "Midnight")
                BackgroundPreviewItem(background: AnyView(MagicBackground.cherry), title: "Cherry")
            }
        }
        .padding()
        .tabItem {
            Image(systemName: "1.circle.fill")
            Text("基础")
        }

        // 自然主题
        VStack(spacing: 20) {
            Group {
                BackgroundPreviewItem(background: AnyView(MagicBackground.mint), title: "Mint", textColor: .primary)
                BackgroundPreviewItem(background: AnyView(MagicBackground.twilight), title: "Twilight")
                BackgroundPreviewItem(background: AnyView(MagicBackground.rose), title: "Rose", textColor: .primary)
                BackgroundPreviewItem(background: AnyView(MagicBackground.emerald), title: "Emerald")
                BackgroundPreviewItem(background: AnyView(MagicBackground.amethyst), title: "Amethyst")
            }

            Group {
                BackgroundPreviewItem(background: AnyView(MagicBackground.coral), title: "Coral", textColor: .primary)
                BackgroundPreviewItem(background: AnyView(MagicBackground.slate), title: "Slate")
                BackgroundPreviewItem(background: AnyView(MagicBackground.sage), title: "Sage", textColor: .primary)
                BackgroundPreviewItem(background: AnyView(MagicBackground.dusk), title: "Dusk")
                BackgroundPreviewItem(background: AnyView(MagicBackground.serenity), title: "Serenity", textColor: .primary)
            }
        }
        .padding()
        .tabItem {
            Image(systemName: "2.circle.fill")
            Text("自然")
        }

        // 透明度效果展示
        VStack(spacing: 20) {
            Text("透明度效果展示")
                .font(.title2)
                .fontWeight(.bold)
                .padding()

            Group {
                BackgroundPreviewItem(background: AnyView(MagicBackground.frost.opacity(0.3)), title: "Frost 30%", textColor: .primary)
                BackgroundPreviewItem(background: AnyView(MagicBackground.gradient.opacity(0.5)), title: "Gradient 50%")
                BackgroundPreviewItem(background: AnyView(MagicBackground.aurora.opacity(0.7)), title: "Aurora 70%")
                BackgroundPreviewItem(background: AnyView(MagicBackground.ocean.opacity(0.4)), title: "Ocean 40%")
                BackgroundPreviewItem(background: AnyView(MagicBackground.sunset.opacity(0.6)), title: "Sunset 60%", textColor: .primary)
            }
        }
        .padding()
        .tabItem {
            Image(systemName: "3.circle.fill")
            Text("透明度")
        }
    }
    .frame(height: 700)
    .frame(width: 900)
}
#endif
