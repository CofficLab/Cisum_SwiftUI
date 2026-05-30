import SwiftUI

/// 相机图标的内部实现
///
/// 这个结构体定义了相机图标的具体实现，包括背景、边框和相机细节。
public struct CameraIcon: View {
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
                // 背景层：绿色到蓝色的渐变，营造科技感
                if useDefaultBackground {
                    LinearGradient(
                        colors: [.green.opacity(0.4), .blue.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                } else {
                    Color.clear
                }

                // 边框层：圆角矩形边框
                RoundedRectangle(cornerRadius: size * 0.2)
                    .stroke(borderColor, lineWidth: size * 0.08)
                    .frame(width: size * 0.9, height: size * 0.9)

                ZStack {
                    // 相机主体：使用系统相机图标
                    Image(systemName: "camera.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: size * 0.5)
                        .foregroundStyle(
                            // 灰黑渐变，模拟相机机身质感
                            .linearGradient(
                                colors: [.gray, .black],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                    // 镜头效果：使用圆形渐变模拟镜头
                    Circle()
                        .fill(
                            .linearGradient(
                                colors: [.blue.opacity(0.8), .cyan.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: size * 0.25) // 镜头大小为整体的1/4
                }
                // 整体阴影效果
                .shadow(color: .black.opacity(0.2), radius: 3, x: 2, y: 2)
            }
        }
    }
}

#if DEBUG
#Preview {
    CameraIconPreviews()
}
#endif
