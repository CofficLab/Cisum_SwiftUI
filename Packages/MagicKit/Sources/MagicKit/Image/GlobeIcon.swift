import SwiftUI

/// 地球图标的内部实现
///
/// 这个结构体定义了地球图标的视觉表现，包括背景、地球轮廓和大陆等元素。
/// 它被 `Image.makeGlobeIcon` 方法使用，通常不需要直接使用此结构体。
public struct GlobeIcon: View {
    /// 是否使用默认的太空背景
    let useDefaultBackground: Bool
    /// 地球轮廓的边框颜色
    let borderColor: Color

    public init(useDefaultBackground: Bool = true, borderColor: Color = .blue) {
        self.useDefaultBackground = useDefaultBackground
        self.borderColor = borderColor
    }

    public var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)

            ZStack {
                // 背景层：深邃的太空渐变
                if useDefaultBackground {
                    LinearGradient(
                        colors: [
                            Color(red: 0.1, green: 0.1, blue: 0.2),
                            Color(red: 0.15, green: 0.15, blue: 0.3),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    // 星星背景
                    ForEach(0 ..< 20) { _ in
                        Circle()
                            .fill(.white)
                            .frame(width: size * 0.01)
                            .offset(
                                x: CGFloat.random(in: -size / 2 ... size / 2),
                                y: CGFloat.random(in: -size / 2 ... size / 2)
                            )
                            .opacity(Double.random(in: 0.3 ... 0.8))
                    }
                } else {
                    Color.clear
                }

                // 边框层：圆角矩形边框
                RoundedRectangle(cornerRadius: size * 0.2)
                    .stroke(borderColor, lineWidth: size * 0.08)
                    .frame(width: size * 0.9, height: size * 0.9)

                ZStack {
                    // 轨道环
                    ForEach(0 ..< 2) { index in
                        Ellipse()
                            .stroke(
                                .linearGradient(
                                    colors: [.blue.opacity(0.6), .cyan.opacity(0.3)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: 2
                            )
                            .frame(width: size * 0.7, height: size * 0.4)
                            .rotationEffect(.degrees(Double(index) * 60))
                            .shadow(color: .blue.opacity(0.3), radius: 4)
                    }

                    // 地球主体
                    ZStack {
                        // 地球底色
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.2, green: 0.5, blue: 0.8),
                                        Color(red: 0.1, green: 0.3, blue: 0.6),
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )

                        // 大陆轮廓
                        ForEach(0 ..< 3) { index in
                            Path { path in
                                path.move(to: CGPoint(x: -20, y: CGFloat(index * 10) - 10))
                                path.addCurve(
                                    to: CGPoint(x: 20, y: CGFloat(index * 8) - 5),
                                    control1: CGPoint(x: -10, y: CGFloat(index * 6)),
                                    control2: CGPoint(x: 10, y: CGFloat(index * 7))
                                )
                            }
                            .stroke(Color.green.opacity(0.6), lineWidth: 4)
                            .frame(width: size * 0.3, height: size * 0.3)
                            .offset(y: CGFloat(index * 8) - 20)
                        }
                    }
                    .frame(width: size * 0.45, height: size * 0.45)
                    .shadow(color: .blue.opacity(0.5), radius: 10)

                    // 卫星
                    Circle()
                        .fill(.white)
                        .frame(width: size * 0.06)
                        .offset(x: size * 0.25, y: -size * 0.15)
                        .shadow(color: .white.opacity(0.5), radius: 4)
                }

                // 大气层光晕效果
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.blue.opacity(0.2), .clear],
                            center: .center,
                            startRadius: size * 0.2,
                            endRadius: size * 0.35
                        )
                    )
                    .frame(width: size * 0.7, height: size * 0.7)
                    .blendMode(.screen)
            }
        }
    }
}
