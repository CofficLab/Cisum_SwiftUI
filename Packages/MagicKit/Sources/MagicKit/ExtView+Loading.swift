import SwiftUI

extension View {
    /// 显示加载状态的修饰符
    /// - Parameters:
    ///   - isLoading: 是否显示加载状态
    ///   - title: 加载提示文本
    ///   - showProgress: 是否显示进度指示器
    /// - Returns: 包装了加载状态的视图
    public func loadingOverlay(
        isLoading: Bool,
        title: String = "加载中...",
        showProgress: Bool = true
    ) -> some View {
        ZStack {
            self
                .disabled(isLoading)

            if isLoading {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)

                MagicLoading(title, showProgress: showProgress)
                    .padding(20)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(radius: 10)
            }
        }
    }

    /// 显示简单的加载指示器覆盖层
    /// - Parameter isLoading: 是否显示加载状态
    /// - Returns: 包装了加载指示器的视图
    public func loadingSpinner(isLoading: Bool) -> some View {
        ZStack {
            self

            if isLoading {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    MagicLoadingView(style: .spinner)
                    Text("请稍候...")
                        .font(.body)
                        .foregroundColor(.white)
                }
                .padding(20)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(radius: 10)
            }
        }
    }

    /// 当加载时显示骨架屏效果
    /// - Parameter isLoading: 是否显示骨架屏
    /// - Returns: 带有骨架屏效果的视图
    public func skeleton(isLoading: Bool) -> some View {
        self.opacity(isLoading ? 0.5 : 1.0)
            .overlay {
                if isLoading {
                    VStack(spacing: 12) {
                        ForEach(0..<3, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 20)
                                .shimmering()
                        }
                    }
                    .padding(.horizontal)
                }
            }
    }
}

/// 骨架屏闪烁效果修饰符
private struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        gradient: Gradient(colors: [.clear, .white.opacity(0.6), .clear]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 2)
                    .offset(x: -geometry.size.width + (geometry.size.width * 2 * phase))
                    .animation(
                        Animation.linear(duration: 1.5)
                            .repeatForever(autoreverses: false),
                        value: phase
                    )
                }
            )
            .onAppear {
                phase = 1
            }
    }
}

extension View {
    /// 添加闪烁效果（用于骨架屏）
    fileprivate func shimmering() -> some View {
        modifier(ShimmerModifier())
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Loading Extensions - Overlay") {
    VStack(spacing: 20) {
        Text("加载覆盖层")
            .font(.headline)

        Text("点击按钮查看加载效果")
            .padding()
            .background(Color.blue.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .loadingOverlay(isLoading: true, title: "正在处理...")

        Text("Spinner 加载")
            .padding()
            .background(Color.green.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .loadingSpinner(isLoading: true)
    }
    .padding()
}

#if DEBUG
#Preview("Loading Extensions - Skeleton") {
    VStack(spacing: 16) {
        Text("骨架屏效果")
            .font(.headline)

        VStack(alignment: .leading, spacing: 12) {
            Text("用户名：John Doe")
                .skeleton(isLoading: true)

            Text("邮箱：john@example.com")
                .skeleton(isLoading: true)

            Text("角色：管理员")
                .skeleton(isLoading: true)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    .padding()
}
#endif

#if DEBUG
#Preview("Loading Extensions - Combined") {
    VStack(spacing: 20) {
        Text("组合使用示例")
            .font(.headline)

        // 正常状态
        VStack(alignment: .leading, spacing: 8) {
            Text("用户信息")
                .font(.headline)
            Text("用户名：John Doe")
            Text("邮箱：john@example.com")
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))

        // 加载状态 - 骨架屏
        VStack(alignment: .leading, spacing: 8) {
            Text("用户信息")
                .font(.headline)
            Text("用户名：John Doe")
                .skeleton(isLoading: true)
            Text("邮箱：john@example.com")
                .skeleton(isLoading: true)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    .padding()
}
#endif
#endif
