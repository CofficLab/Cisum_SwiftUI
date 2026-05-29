import SwiftUI

/// 铅笔图标的内部实现
public struct PencilIcon: View {
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
                if useDefaultBackground {
                    MagicBackground.forest
                }

                // 圆角矩形边框
                RoundedRectangle(cornerRadius: size * 0.2)
                    .stroke(borderColor, lineWidth: size * 0.08)
                    .frame(width: size * 0.9, height: size * 0.9)

                // 使用系统铅笔图标
                Image(systemName: "pencil")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size * 0.3)
                    .foregroundStyle(
                        .linearGradient(
                            colors: [.brown, Color(red: 0.4, green: 0.8, blue: 0.8), .blue],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .rotationEffect(.degrees(0))
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 1, y: 1)
            }
        }
    }
}
