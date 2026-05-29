import SwiftUI

extension MagicBackground {
    public static var jazzNight: some View {
        ZStack {
            // 深蓝夜色渐变
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "1A237E").opacity(0.7), // 深靛蓝
                    Color(hex: "000051").opacity(0.6), // 午夜蓝
                ]),
                startPoint: .top,
                endPoint: .bottom
            )

            // 音符装饰
            GeometryReader { geometry in
                // 简化的音符图案
                Path { path in
                    path.addEllipse(in: CGRect(x: geometry.size.width * 0.3,
                                               y: geometry.size.height * 0.4,
                                               width: 20, height: 15))
                    path.move(to: CGPoint(x: geometry.size.width * 0.3 + 20,
                                          y: geometry.size.height * 0.4 + 7.5))
                    path.addLine(to: CGPoint(x: geometry.size.width * 0.3 + 20,
                                             y: geometry.size.height * 0.4 - 30))
                }
                .stroke(Color.white.opacity(0.3), lineWidth: 2)
            }
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }

    public static var classicalHarmony: some View {
        ZStack {
            // 优雅的米色渐变
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "D1C4E9").opacity(0.7), // 淡紫色
                    Color(hex: "F3E5F5").opacity(0.6), // 浅粉紫
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // 五线谱效果
            VStack(spacing: 10) {
                ForEach(0 ..< 5) { _ in
                    Rectangle()
                        .fill(Color.black.opacity(0.1))
                        .frame(height: 1)
                }
            }
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }

    public static var rockStage: some View {
        ZStack {
            // 深色舞台渐变
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "D32F2F").opacity(0.7), // 深红色
                    Color(hex: "311B92").opacity(0.6), // 深紫色
                ]),
                startPoint: .bottom,
                endPoint: .top
            )

            // 聚光灯效果
            Circle()
                .fill(Color.white.opacity(0.2))
                .frame(width: 200)
                .blur(radius: 50)
                .offset(y: -50)
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }

    public static var electronicBeats: some View {
        ZStack {
            // 霓虹色彩渐变
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "00BCD4").opacity(0.7), // 青色
                    Color(hex: "7C4DFF").opacity(0.6), // 紫色
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )

            // 音波效果
            HStack(spacing: 15) {
                ForEach(0 ..< 4) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 4, height: 40.0 + Double(index) * 20)
                }
            }
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }

    public static var acousticMorning: some View {
        ZStack {
            // 温暖的晨光渐变
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "FFE0B2").opacity(0.7), // 暖橙色
                    Color(hex: "FFECB3").opacity(0.6), // 浅黄色
                ]),
                startPoint: .top,
                endPoint: .bottom
            )

            // 吉他弦效果
            VStack(spacing: 12) {
                ForEach(0 ..< 6) { _ in
                    Capsule()
                        .fill(Color.black.opacity(0.1))
                        .frame(width: 200, height: 1)
                }
            }
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
}

#if DEBUG
#Preview("Music Themes") {
    TabView {
        // 音乐主题
        ScrollView {
            VStack(spacing: 20) {
                Text("音乐主题")
                    .font(.headline)
                    .padding(.top)

                Group {
                    BackgroundPreviewItem(
                        background: AnyView(MagicBackground.jazzNight),
                        title: "Jazz Night"
                    )

                    BackgroundPreviewItem(
                        background: AnyView(MagicBackground.classicalHarmony),
                        title: "Classical Harmony",
                        textColor: .primary
                    )

                    BackgroundPreviewItem(
                        background: AnyView(MagicBackground.rockStage),
                        title: "Rock Stage"
                    )

                    BackgroundPreviewItem(
                        background: AnyView(MagicBackground.electronicBeats),
                        title: "Electronic Beats"
                    )

                    BackgroundPreviewItem(
                        background: AnyView(MagicBackground.acousticMorning),
                        title: "Acoustic Morning",
                        textColor: .primary
                    )
                }
            }
            .padding()
        }

        .tabItem {
            Image(systemName: "music.note")
            Text("音乐")
        }
    }
}
#endif

// MARK: - View Extensions

