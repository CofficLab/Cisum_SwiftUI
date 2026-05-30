import SwiftUI

/// Image 扩展，提供创建视频播放器图标的功能
public extension Image {
    /// 创建一个自定义的视频播放器图标
    ///
    /// 此方法创建一个可自定义的视频播放器图标，可用于应用中表示视频播放、媒体内容或影院等概念。
    ///
    /// - Parameters:
    ///   - useDefaultBackground: 是否使用默认的深色渐变背景，默认为 true
    ///   - borderColor: 图标边框的颜色，默认为蓝色
    ///   - size: 图标的大小，如果为 nil 则使用容器默认大小
    /// - Returns: 一个可以在 SwiftUI 视图中使用的视频播放器图标视图
    ///
    /// ## 使用示例:
    /// ```swift
    /// // 创建默认视频播放器图标
    /// Image.makeVideoPlayerIcon()
    ///
    /// // 创建自定义视频播放器图标
    /// Image.makeVideoPlayerIcon(
    ///     useDefaultBackground: false,
    ///     borderColor: .red,
    ///     size: 80
    /// )
    /// ```
    static func makeVideoPlayerIcon(
        useDefaultBackground: Bool = true,
        borderColor: Color = .blue,
        size: CGFloat? = nil
    ) -> some View {
        IconContainer(size: size) {
            VideoPlayerIcon(
                useDefaultBackground: useDefaultBackground,
                borderColor: borderColor
            )
        }
    }
}

/// 视频播放器图标的内部实现
///
/// 这个结构体定义了视频播放器图标的视觉表现，包括背景、边框和播放控件等元素。
/// 它被 `Image.makeVideoPlayerIcon` 方法使用，通常不需要直接使用此结构体。
struct VideoPlayerIcon: View {
    /// 是否使用默认的深色渐变背景
    let useDefaultBackground: Bool
    /// 播放器边框的颜色
    let borderColor: Color

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)

            ZStack {
                // 背景层：深色渐变背景，营造影院氛围
                if useDefaultBackground {
                    LinearGradient(
                        colors: [
                            Color(red: 0.1, green: 0.1, blue: 0.2),
                            Color(red: 0.2, green: 0.2, blue: 0.3),
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
                    // 电影胶片效果
                    Image(systemName: "film")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: size * 0.6)
                        .foregroundStyle(
                            // 银色渐变，模拟胶片质感
                            .linearGradient(
                                colors: [.gray.opacity(0.8), .white.opacity(0.9)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    // 播放按钮：居中偏下
                    Image(systemName: "play.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: size * 0.35)
                        .foregroundStyle(
                            // 红色渐变，突出播放按钮
                            .linearGradient(
                                colors: [.red.opacity(0.9), .orange.opacity(0.8)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .offset(y: size * 0.05) // 稍微向下偏移
                }
                .shadow(color: .black.opacity(0.3), radius: 4, x: 2, y: 3)

                // 装饰性光效：顶部光晕
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.white.opacity(0.3), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: size * 0.3
                        )
                    )
                    .frame(width: size * 0.4)
                    .offset(y: -size * 0.2)
                    .blendMode(.softLight)
            }
        }
    }
}

#if DEBUG
#Preview {
    IconPreviewHelper(title: "Video Player Icon") {
        Image.makeVideoPlayerIcon()
    }
}
#endif
