import SwiftUI

/// 笔记图标的内部实现
public struct NoteIcon: View {
    let useDefaultBackground: Bool
    let borderColor: Color

    public init(useDefaultBackground: Bool = true, borderColor: Color = .blue) {
        self.useDefaultBackground = useDefaultBackground
        self.borderColor = borderColor
    }

    public var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)

            ZStack {
                // 背景层：温暖的米色渐变，营造纸张质感
                if useDefaultBackground {
                    LinearGradient(
                        colors: [
                            Color(red: 0.95, green: 0.95, blue: 0.9),
                            Color(red: 0.9, green: 0.9, blue: 0.85),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }

                // 边框层：圆角矩形边框
                RoundedRectangle(cornerRadius: size * 0.2)
                    .stroke(borderColor, lineWidth: size * 0.08)
                    .frame(width: size * 0.9, height: size * 0.9)

                ZStack {
                    // 便签纸效果：多层叠加
                    ForEach(0 ..< 3) { index in
                        RoundedRectangle(cornerRadius: size * 0.05)
                            .fill(
                                LinearGradient(
                                    colors: [.white, Color(white: 0.95)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: size * 0.6, height: size * 0.6)
                            .rotationEffect(.degrees(Double(index * 3) - 3))
                            .offset(
                                x: CGFloat(index * 5) - 5,
                                y: CGFloat(index * 5) - 5
                            )
                            .shadow(color: .black.opacity(0.1), radius: 1, x: 1, y: 1)
                    }

                    // 横线装饰
                    VStack(spacing: size * 0.08) {
                        ForEach(0 ..< 3) { _ in
                            Rectangle()
                                .fill(Color.blue.opacity(0.3))
                                .frame(width: size * 0.4, height: 1)
                        }
                    }
                    .offset(x: -size * 0.05)

                    // 钢笔图标
                    Image(systemName: "fountain.pen.tip")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: size * 0.35)
                        .rotationEffect(.degrees(-45))
                        .offset(x: size * 0.15, y: -size * 0.05)
                        .foregroundStyle(
                            // 金属质感渐变
                            .linearGradient(
                                colors: [
                                    .gray.opacity(0.8),
                                    .white.opacity(0.9),
                                    .gray.opacity(0.8),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    // 墨水痕迹
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: size * 0.1)
                        .offset(x: -size * 0.15, y: size * 0.15)
                        .blur(radius: 2)
                }
                // 整体阴影效果
                .shadow(color: .black.opacity(0.2), radius: 4, x: 2, y: 3)
            }
        }
    }
}
