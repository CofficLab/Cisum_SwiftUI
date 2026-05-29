import SwiftUI

/// 魔法加载视图组件
/// 提供多种加载动画样式的独立视图组件
public struct MagicLoadingView: View {
    /// 加载动画样式
    public enum Style {
        case spinner
        case dots
        case pulse
        case none
    }
    
    /// 加载动画样式
    let style: Style
    /// 是否正在加载
    let isLoading: Bool
    /// 前景色
    let foregroundColor: Color
    
    /// 初始化魔法加载视图
    /// - Parameters:
    ///   - style: 加载动画样式
    ///   - isLoading: 是否正在加载
    ///   - foregroundColor: 前景色
    public init(
        style: Style = .spinner,
        isLoading: Bool = true,
        foregroundColor: Color = .primary
    ) {
        self.style = style
        self.isLoading = isLoading
        self.foregroundColor = foregroundColor
    }
    
    public var body: some View {
        loadingView
    }
    
    /// 加载视图内容
    @ViewBuilder
    private var loadingView: some View {
        switch style {
        case .spinner:
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(0.8)
                .frame(minWidth: 20, idealWidth: 20, maxWidth: 20, minHeight: 20, idealHeight: 20, maxHeight: 20)
                .fixedSize()
        case .dots:
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(foregroundColor)
                        .frame(width: 6, height: 6)
                        .scaleEffect(isLoading ? 1.0 : 0.5)
                        .animation(
                            Animation.easeInOut(duration: 0.6)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.2),
                            value: isLoading
                        )
                }
            }
        case .pulse:
            Circle()
                .fill(foregroundColor)
                .frame(width: 20, height: 20)
                .scaleEffect(isLoading ? 1.2 : 0.8)
                .opacity(isLoading ? 0.6 : 1.0)
                .animation(
                    Animation.easeInOut(duration: 1.0)
                        .repeatForever(autoreverses: true),
                    value: isLoading
                )
        case .none:
            EmptyView()
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview("MagicLoadingView") {
    VStack(spacing: 20) {
        Text("加载动画样式")
            .font(.headline)
        
        VStack(spacing: 16) {
            Text("Spinner").font(.subheadline)
            MagicLoadingView(style: .spinner)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        
        VStack(spacing: 16) {
            Text("Dots").font(.subheadline)
            MagicLoadingView(style: .dots, foregroundColor: .blue)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        
        VStack(spacing: 16) {
            Text("Pulse").font(.subheadline)
            MagicLoadingView(style: .pulse, foregroundColor: .green)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    .padding()
    
}
#endif
