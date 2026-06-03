import SwiftUI

extension AvatarView {
    /// 下载进度视图组件
    struct DownloadingView: View {
        let progress: Double
        let shape: AvatarViewShape
        let size: CGSize
        let backgroundColor: Color

        init(
            progress: Double,
            shape: AvatarViewShape = .circle,
            size: CGSize,
            backgroundColor: Color = .blue.opacity(0.1)
        ) {
            self.progress = progress
            self.shape = shape
            self.size = size
            self.backgroundColor = backgroundColor
        }
        
        var padding: CGFloat {
            return self.size.width * 0.1
        }

        var body: some View {
            ZStack {
                Circle()
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 4)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.accentColor, style: StrokeStyle(
                        lineWidth: 4,
                        lineCap: .round
                    ))
                    .rotationEffect(.degrees(-90))

                Text("\(Int(progress * 100))%")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(padding)
            .frame(width: size.width, height: size.height)
            .background(backgroundColor)
            .clipShape(shape)
        }
    }
}

