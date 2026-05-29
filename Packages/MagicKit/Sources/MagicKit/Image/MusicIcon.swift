import SwiftUI

/// 音乐图标的内部实现
public struct MusicIcon: View {
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
                // 背景层：粉色到紫色的渐变，营造音乐的活力感
                if useDefaultBackground {
                    LinearGradient(
                        colors: [.pink.opacity(0.4), .purple.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }

                // 边框层：圆角矩形边框
                RoundedRectangle(cornerRadius: size * 0.2)
                    .stroke(borderColor, lineWidth: size * 0.08)
                    .frame(width: size * 0.9, height: size * 0.9)

                // 音符图标层：使用两个错开的音符创造层次感
                ZStack {
                    // 大音符：靠右放置
                    Image(systemName: "music.note")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: size * 0.4)
                        .foregroundStyle(
                            // 蓝紫粉渐变，从上到下
                            .linearGradient(
                                colors: [.blue, .purple, .pink],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .offset(x: size * 0.1)

                    // 小音符：靠左放置，颜色反向
                    Image(systemName: "music.note")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: size * 0.3)
                        .foregroundStyle(
                            .linearGradient(
                                colors: [.pink, .purple, .blue],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .offset(x: -size * 0.1)
                }
                // 整体阴影效果
                .shadow(color: .black.opacity(0.2), radius: 3, x: 2, y: 2)
            }
        }
    }
}
