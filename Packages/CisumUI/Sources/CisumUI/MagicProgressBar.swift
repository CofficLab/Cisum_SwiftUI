import SwiftUI

public struct MagicProgressBar: View {
    @Binding var currentTime: TimeInterval
    @State private var isDragging = false
    @State private var dragTime: TimeInterval
    @State private var isHovering = false
    @Environment(\.colorScheme) private var colorScheme

    let duration: TimeInterval
    let onSeek: ((TimeInterval) -> Void)?

    public init(
        currentTime: Binding<TimeInterval>,
        duration: TimeInterval,
        onSeek: ((TimeInterval) -> Void)? = nil
    ) {
        self._currentTime = currentTime
        self._dragTime = State(initialValue: currentTime.wrappedValue)
        self.duration = duration
        self.onSeek = onSeek
    }

    public var body: some View {
        VStack(spacing: 8) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    Capsule()
                        .fill(Color.primary.opacity(isHovering ? 0.15 : 0.1))
                        .frame(height: 4)

                    // Progress track
                    Capsule()
                        .fill(Color.accentColor.opacity(isHovering ? 1 : 0.8))
                        .frame(width: geometry.size.width * progress, height: 4)

                    // Drag handle
                    Circle()
                        .fill(Color.white)
                        .frame(width: isHovering ? 16 : 12, height: isHovering ? 16 : 12)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.5), lineWidth: 1)
                        )
                        .shadow(
                            color: Color.black.opacity(isHovering ? 0.25 : 0.15),
                            radius: isHovering ? 6 : 4,
                            y: isHovering ? 3 : 2
                        )
                        .shadow(
                            color: Color.black.opacity(0.1),
                            radius: 1,
                            y: 0
                        )
                        .offset(x: geometry.size.width * progress - (isHovering ? 8 : 6))
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovering)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    isDragging = true
                                    let newTime = min(max(0, value.location.x / geometry.size.width), 1) * duration
                                    withAnimation(.linear(duration: 0.1)) {
                                        dragTime = newTime
                                    }
                                }
                                .onEnded { value in
                                    isDragging = false
                                    let finalTime = min(max(0, value.location.x / geometry.size.width), 1) * duration
                                    currentTime = finalTime
                                    dragTime = currentTime
                                    onSeek?(finalTime)
                                }
                        )
                }
                .contentShape(Rectangle())
                .onTapGesture { location in
                    let newTime = min(max(0, location.x / geometry.size.width), 1) * duration
                    currentTime = newTime
                    dragTime = currentTime
                    onSeek?(newTime)
                }
                .onHover { hovering in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isHovering = hovering
                    }
                }
            }
            .frame(height: 20)

            // Time labels
            HStack {
                TimeLabel(
                    time: isDragging ? dragTime : currentTime,
                    isProgressBarHovering: isHovering
                )

                Spacer()

                TimeLabel(
                    time: duration,
                    isProgressBarHovering: isHovering
                )
            }
        }
    }

    private var progress: CGFloat {
        let time = isDragging ? dragTime : currentTime
        return duration > 0 ? CGFloat(time / duration) : 0
    }
}

private struct TimeLabel: View {
    let time: TimeInterval
    let isProgressBarHovering: Bool
    @State private var isHovering = false

    var body: some View {
        Text(formatTime(time))
            .font(.caption)
            .foregroundStyle(isProgressBarHovering || isHovering ? .primary : .secondary)
            .opacity(isProgressBarHovering || isHovering ? 1 : 0.8)
            .scaleEffect(isHovering ? 1.1 : 1)
            .animation(
                .spring(response: 0.3, dampingFraction: 0.7),
                value: isProgressBarHovering || isHovering
            )
            .onHover { hovering in
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isHovering = hovering
                }
            }
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#if DEBUG
#Preview("MagicProgressBar") {
    TabView {
        // 基础用法
        VStack(spacing: 20) {
            Text("基础进度条")
                .font(.headline)

            MagicProgressBar(
                currentTime: .constant(72),
                duration: 240
            )
            .frame(width: 300)
        }
        .padding()

        .tabItem {
            Image(systemName: "1.circle.fill")
            Text("基础")
        }

        // 交互示例
        VStack(spacing: 20) {
            Text("交互进度条")
                .font(.headline)

            MagicProgressBar(
                currentTime: .constant(120),
                duration: 240,
                onSeek: { newTime in
                    print("Seeked to: \(newTime)")
                }
            )
            .frame(width: 300)
        }
        .padding()

        .tabItem {
            Image(systemName: "2.circle.fill")
            Text("交互")
        }

        // 不同长度
        VStack(spacing: 20) {
            Text("不同长度")
                .font(.headline)

            Group {
                Text("短进度条").font(.subheadline)
                MagicProgressBar(
                    currentTime: .constant(30),
                    duration: 60
                )
                .frame(width: 200)
            }

            Group {
                Text("中等进度条").font(.subheadline)
                MagicProgressBar(
                    currentTime: .constant(150),
                    duration: 300
                )
                .frame(width: 300)
            }

            Group {
                Text("长进度条").font(.subheadline)
                MagicProgressBar(
                    currentTime: .constant(300),
                    duration: 600
                )
                .frame(width: 400)
            }
        }
        .padding()

        .tabItem {
            Image(systemName: "3.circle.fill")
            Text("长度")
        }

        // 动态更新
        DynamicProgressBarPreview()
            .tabItem {
                Image(systemName: "4.circle.fill")
                Text("动态")
            }
    }
}
#endif

// MARK: - Dynamic Preview

private struct DynamicProgressBarPreview: View {
    @State private var currentTime: TimeInterval = 0
    let duration: TimeInterval = 300
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 20) {
            Text("动态更新")
                .font(.headline)

            MagicProgressBar(
                currentTime: $currentTime,
                duration: duration,
                onSeek: { newTime in
                    currentTime = newTime
                }
            )
            .frame(width: 300)

            HStack {
                Button(action: { currentTime = 0 }) {
                    Image(systemName: "backward.end.fill")
                }

                Button(action: { currentTime = duration }) {
                    Image(systemName: "forward.end.fill")
                }
            }
            .buttonStyle(.plain)
            .font(.title2)
        }
        .padding()
        .onReceive(timer) { _ in
            if currentTime < duration {
                currentTime += 1
            }
        }
    }
}
